import numpy as np, potrace

idx=np.load('/tmp/vec/idx.npy'); h,w=idx.shape
names=['ground','blush','pink','pinkdeep','sage','sagepale','ink']
HEX={'ground':'#F7F1EF','blush':'#F0E2DE','pink':'#ECD4D6','pinkdeep':'#E0B8BD',
     'sage':'#CBD2BC','sagepale':'#E0E1D4','ink':'#2B1512'}
I={n:i for i,n in enumerate(names)}

def dilate(m,n=1):
    o=m.copy()
    for _ in range(n):
        p=o.copy()
        p[1:,:]|=o[:-1,:]; p[:-1,:]|=o[1:,:]
        p[:,1:]|=o[:,:-1]; p[:,:-1]|=o[:,1:]
        o=p
    return o

ink_core = idx==I['ink']
unknown  = dilate(ink_core,2)          # ink + its antialias ring
ink_draw = dilate(ink_core,1)          # trace slightly fat so no pale halo survives

# fill the unknown band from the surrounding solid block colours
filled=idx.copy(); todo=unknown.copy()
while todo.any():
    nb=np.full((h,w),-1,np.int32)
    src=np.where(todo,-1,filled)
    for dy,dx in ((1,0),(-1,0),(0,1),(0,-1)):
        sh=np.roll(src,(dy,dx),(0,1))
        if dy==1: sh[0,:]=-1
        if dy==-1: sh[-1,:]=-1
        if dx==1: sh[:,0]=-1
        if dx==-1: sh[:,-1]=-1
        t=todo&(nb<0)&(sh>=0); nb[t]=sh[t]
    prog=todo&(nb>=0)
    if not prog.any(): break
    filled[prog]=nb[prog]; todo&=~prog

def trace(mask,turd=6,opttol=0.25):
    path=potrace.Bitmap(~mask).trace(turdsize=turd,alphamax=1.0,opticurve=True,opttolerance=opttol)
    f=lambda v: round(float(v),2); out=[]
    for c in path:
        d=['M%g %g'%(f(c.start_point.x),f(c.start_point.y))]
        for s in c.segments:
            if s.is_corner:
                d.append('L%g %g L%g %g'%(f(s.c.x),f(s.c.y),f(s.end_point.x),f(s.end_point.y)))
            else:
                d.append('C%g %g %g %g %g %g'%(f(s.c1.x),f(s.c1.y),f(s.c2.x),f(s.c2.y),
                                               f(s.end_point.x),f(s.end_point.y)))
        d.append('Z'); out.append(''.join(d))
    return ' '.join(out)

p=[f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}" '
   f'preserveAspectRatio="xMidYMid slice" role="presentation" aria-hidden="true">',
   f'<rect width="{w}" height="{h}" fill="{HEX["ground"]}"/>']
for n in ['sage','pink','blush','pinkdeep','sagepale']:
    p.append(f'<path fill="{HEX[n]}" fill-rule="evenodd" d="{trace(dilate(filled==I[n],1))}"/>')
p.append(f'<path fill="{HEX["ink"]}" fill-rule="evenodd" d="{trace(ink_draw,turd=4,opttol=0.2)}"/>')
p.append('</svg>')
svg='\n'.join(p); open('/tmp/vec/welcome-supergraphic.svg','w').write(svg); print('bytes',len(svg))

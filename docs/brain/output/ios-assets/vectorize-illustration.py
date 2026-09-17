import numpy as np, potrace
from PIL import Image
import sys

SRC=sys.argv[1]; OUT=sys.argv[2]
PAL=[('outline','#41112B',(0x41,0x11,0x2B)),
     ('darkred','#7E1B30',(0x7E,0x1B,0x30)),
     ('red',    '#A72A3C',(0xA7,0x2A,0x3C)),
     ('sage',   '#98A472',(0x98,0xA4,0x72)),
     ('peach',  '#F8B7A5',(0xF8,0xB7,0xA5)),
     ('yolk',   '#F6C978',(0xF6,0xC9,0x78)),
     ('beige',  '#EED6B2',(0xEE,0xD6,0xB2)),
     ('cream',  '#F6F1ED',(0xF6,0xF1,0xED))]
NAMES=[p[0] for p in PAL]; HEX={p[0]:p[1] for p in PAL}
COLS=np.array([p[2] for p in PAL],dtype=np.int32)
TRANS=len(PAL)                     # extra class id

im=Image.open(SRC).convert('RGBA'); a=np.array(im).astype(np.int32)
h,w=a.shape[:2]; rgb=a[:,:,:3]; al=a[:,:,3]
d=((rgb[:,:,None,:]-COLS[None,None,:,:])**2).sum(-1)
idx=d.argmin(-1).astype(np.int32)
idx[al<128]=TRANS

def dilate(m,n=1):
    o=m.copy()
    for _ in range(n):
        p=o.copy()
        p[1:,:]|=o[:-1,:]; p[:-1,:]|=o[1:,:]
        p[:,1:]|=o[:,:-1]; p[:,:-1]|=o[:,1:]
        o=p
    return o

ink=idx==NAMES.index('outline')
unknown=dilate(ink,2)
ink_draw=ink

filled=idx.copy(); todo=unknown.copy()
while todo.any():
    nb=np.full((h,w),-1,np.int32); src=np.where(todo,-1,filled)
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

def trace(mask,turd=8,opttol=0.3):
    if mask.sum()==0: return ''
    path=potrace.Bitmap(~mask).trace(turdsize=turd,alphamax=1.0,opticurve=True,opttolerance=opttol)
    f=lambda v: round(float(v),1); out=[]
    for c in path:
        dd=['M%g %g'%(f(c.start_point.x),f(c.start_point.y))]
        for s in c.segments:
            if s.is_corner:
                dd.append('L%g %g L%g %g'%(f(s.c.x),f(s.c.y),f(s.end_point.x),f(s.end_point.y)))
            else:
                dd.append('C%g %g %g %g %g %g'%(f(s.c1.x),f(s.c1.y),f(s.c2.x),f(s.c2.y),
                                                f(s.end_point.x),f(s.end_point.y)))
        dd.append('Z'); out.append(''.join(dd))
    return ' '.join(out)

p=[f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}" '
   f'role="presentation" aria-hidden="true">']
for n in ['cream','sage','red','peach','beige','yolk','darkred']:
    m=filled==NAMES.index(n)
    if m.sum()<40: continue
    dsl=trace(dilate(m,1))
    if dsl: p.append(f'<path fill="{HEX[n]}" fill-rule="evenodd" d="{dsl}"/>')
p.append(f'<path fill="{HEX["outline"]}" fill-rule="evenodd" d="{trace(ink_draw,turd=3,opttol=0.2)}"/>')
p.append('</svg>')
svg='\n'.join(p); open(OUT,'w').write(svg); print('bytes',len(svg))

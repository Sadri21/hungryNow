import numpy as np
from PIL import Image
import potrace

SRC='output/mockups/welcome-supergraphic.png'
PAL = {
 'ground'   :(0xF7,0xF1,0xEF),
 'blush'    :(0xF0,0xE2,0xDE),
 'pink'     :(0xEC,0xD4,0xD6),
 'pinkdeep' :(0xE0,0xB8,0xBD),
 'sage'     :(0xCB,0xD2,0xBC),
 'sagepale' :(0xE0,0xE1,0xD4),
 'ink'      :(0x2B,0x15,0x12),
}
names=list(PAL); cols=np.array([PAL[n] for n in names],dtype=np.int32)

im=np.array(Image.open(SRC).convert('RGB')).astype(np.int32)
h,w,_=im.shape
d=((im[:,:,None,:]-cols[None,None,:,:])**2).sum(-1)
idx=d.argmin(-1)                      # nearest palette index per pixel
print('size',w,h)
for i,n in enumerate(names): print(n,(idx==i).sum())
np.save('/tmp/vec/idx.npy',idx)

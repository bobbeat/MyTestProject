#include "stdlib.h"

#ifndef uiBYTE
#define uiBYTE unsigned char
#endif

#ifndef uiWORD
#define uiWORD unsigned short
#endif

#ifndef uiDWORD
#define uiDWORD unsigned int
#endif

#ifndef uiBOOL
#define uiBOOL int
#endif

#ifndef uiUINT
#define uiUINT uiDWORD
#endif

#ifndef uiNULL
#define uiNULL 0
#endif

#define BGR565_MASK_BLUE    0xF800
#define BGR565_MASK_GREEN   0x07E0
#define BGR565_MASK_RED     0x001F


#define   RGB555_MASK_RED				0x00007C00
#define   RGB555_MASK_GREEN             0x000003E0
#define   RGB555_MASK_BLUE              0x0000001F

// ∏ﬂ◊÷‘⁄«∞£¨µÕ◊÷‘⁄∫Û
#define MAKEDWORD(h, l)     ((uiDWORD)(((uiWORD)((uiDWORD)(l) & 0xffff)) | ((uiDWORD)((uiWORD)((uiDWORD)(h) & 0xffff))) << 16))
#define MAKEWORD(h, l)      ((uiWORD)(((uiBYTE)((uiDWORD)(l) & 0xff)) | ((uiWORD)((uiBYTE)((uiDWORD)(h) & 0xff))) << 8))


#define _565R(clr565)   (((uiWORD)((uiDWORD)clr565&BGR565_MASK_RED))<<3)
#define _565G(clr565)   (((uiWORD)((uiDWORD)clr565&BGR565_MASK_GREEN))>>3)
#define _565B(clr555) (((uiWORD)((uiDWORD)clr565&BGR565_MASK_BLUE))>>8)

#define	  _555R(clr555)		(((uiWORD)((uiDWORD)clr555&RGB555_MASK_RED))>>7)
#define   _555G(clr555)		(((uiWORD)((uiDWORD)clr555&RGB555_MASK_GREEN))>>2)
#define   _555B(clr555)		(((uiWORD)((uiDWORD)clr555&RGB555_MASK_BLUE))<<3)
//#define   MAKE_RGB(r,g,b)	((((uiDWORD)(uiBYTE)(b))<<16) | (((uiDWORD)(uiBYTE)(g))<<8) | ((uiBYTE)(r)))
#define	  MAKE_RGB(r,g,b)	((uiDWORD)(((uiBYTE)(r)|((uiWORD)((uiBYTE)(g))<<8))|(((uiDWORD)(uiBYTE)(b))<<16)))
#define   MAKECOLOR(a,r,g,b)((uiDWORD)(((uiDWORD)(uiBYTE)(a))<<24 | MAKE_RGB(r,g,b)))
uiDWORD* LoadBMP565(uiBYTE* aBmpStream, int aBytes ,uiBYTE * alpha);
uiDWORD* LoadBMP(uiBYTE* aBmpStream, int aBytes, uiDWORD aMaskClr, int* aWidth, int* aHeight);
unsigned char* Convert565_888(unsigned char* aBmpStream,int nWidth,int nHeight,unsigned char* alpha);


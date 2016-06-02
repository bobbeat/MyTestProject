#include "load_bmp.h"
// aHeight£∫Õº∆¨∏ﬂ∂»
uiDWORD* LoadBMP(uiBYTE* aBmpStream, int aBytes, uiDWORD aMaskClr, int* aWidth, int* aHeight)//, struct tagGDBitmap* aOutPut24)
{
#pragma pack(1)
	typedef struct tagGDRGBQUAD 
	{
        uiBYTE    rgbBlue;
        uiBYTE    rgbGreen;
        uiBYTE    rgbRed;
        uiBYTE    rgbReserved;
	} GDRGBQUAD;
	
	typedef struct tagGDBITMAPINFOHEADER
	{
        uiDWORD      biSize;
        long       biWidth;
        long       biHeight;
        uiWORD       biPlanes;
        uiWORD       biBitCount;
        uiDWORD      biCompression;
        uiDWORD      biSizeImage;
        long       biXPelsPerMeter;
        long       biYPelsPerMeter;
        uiDWORD      biClrUsed;
        uiDWORD      biClrImportant;
	} GDBITMAPINFOHEADER;
	
	typedef struct tagGDBITMAPINFO 
	{
		GDBITMAPINFOHEADER    bmiHeader;
		GDRGBQUAD             bmiColors[1];
	} GDBITMAPINFO;
	
	typedef struct tagGDBITMAPFILEHEADER 
	{
        uiWORD    bfType;
        uiDWORD   bfSize;
        uiWORD    bfReserved1;
        uiWORD    bfReserved2;
        uiDWORD   bfOffBits;
	} GDBITMAPFILEHEADER;
#pragma pack()
	
	//#define BI_RGB 0L
	
	uiDWORD* argb = NULL;
	
	
	// Õº∆¨…´≈Ãª∫≥Â
	uiBYTE bmpBuffer[sizeof(GDBITMAPINFOHEADER) + 256 * sizeof(GDRGBQUAD)];
	GDBITMAPFILEHEADER Head;
	GDBITMAPINFOHEADER bih;
	GDBITMAPINFO *pbi = uiNULL;
	long bufsize=0;
	int pitch = 0;
	
	if (aBmpStream == uiNULL || aBytes <= 0)
	{
		return NULL;
	}
	
	// ∂¡Œƒº˛Õ∑
	memset(bmpBuffer, 0, sizeof(bmpBuffer));
	pbi = (GDBITMAPINFO*)bmpBuffer;
	
	memcpy(&Head, aBmpStream, sizeof(GDBITMAPFILEHEADER));
	aBmpStream += sizeof(GDBITMAPFILEHEADER);
	memcpy(&bih, aBmpStream, sizeof(GDBITMAPINFOHEADER));
	aBmpStream += sizeof(GDBITMAPINFOHEADER);
	
	pitch = ((bih.biWidth*bih.biBitCount+31)>>5)<<2;
	
	// 
	if (bih.biBitCount <= 8)
	{
		// 8ŒªÀ˜“˝Õº∆¨
		if(bih.biClrUsed == 0)
		{
			bih.biClrUsed = 256;
		}
		// ∂¡…´≈Ã
		memcpy(pbi->bmiColors, aBmpStream, sizeof(GDRGBQUAD)*bih.biClrUsed);
		aBmpStream += sizeof(GDRGBQUAD)*bih.biClrUsed;
	}
	
	// Õ≥“ªº”‘ÿ≥…24ŒªµƒGDBitmap
	// 	aOutPut24->iSize.width = bih.biWidth;
	// 	aOutPut24->iSize.height = bih.biHeight;
	// 	aOutPut24->iBitsPixel = 24;
	// 	aOutPut24->iAlpha = uiNULL;
	// 	aOutPut24->iMask = MASKTYPE_COLOR;
	// 	aOutPut24->iTransparent = 0x00FF00FF;
	
	
	bufsize = bih.biWidth*bih.biHeight*4;//aOutPut24->iSize.width*aOutPut24->iSize.height*3;
	*aWidth = bih.biWidth;
	*aHeight = bih.biHeight;
	// Õ≥“ªº”‘ÿ≥…ARGB∏Ò Ωµƒ—’…´ ˝÷µ
	argb = (uiDWORD*)malloc(bufsize);
	
	if(bufsize)
	{
		
		// RGB
		// 		aOutPut24->iBgr = (uiBYTE*)malloc(bufsize);
		// 		if(aOutPut24->iBgr == uiNULL)
		// 		{
		// 			return NULL;
		// 		}
		
		// —’…´÷µ◊™ªª
		if(bih.biBitCount <= 8)
		{
			int k=0;
			int i=0;
			int j=0;
			int idx=0;
			int index = (bih.biHeight-1)*pitch;
			
			// »Áπ˚—⁄¥a…´ûÈ0£¨ƒ«√¥»°◊Û…œΩ«µ⁄“ªÇÄœÒÀÿµƒÓÅ…´◊˜ûÈ—⁄¥a…´°£
			// ÷ÆÀ˘“‘◊ˆﬂ@ÇÄ‘O”ãºÉ¥‚ «“ÚûÈ∑≈¥Û¬∑ø⁄º˝Ó^àD∆¨µƒµ◊…´≤ª»´ «0xFF00FFåß÷¬
			if(aMaskClr==0)
			{
				idx = aBmpStream[index];
				aMaskClr = MAKE_RGB(pbi->bmiColors[idx].rgbBlue,pbi->bmiColors[idx].rgbGreen,pbi->bmiColors[idx].rgbRed);
			}
			
			for(i=0; i<bih.biHeight; i++)
			{
				for(j=0; j<bih.biWidth; j++)
				{
					idx = aBmpStream[index+j];
					// 					aOutPut24->iBgr[k++] = pbi->bmiColors[idx].rgbBlue;
					// 					aOutPut24->iBgr[k++] = pbi->bmiColors[idx].rgbGreen;
					// 					aOutPut24->iBgr[k++] = pbi->bmiColors[idx].rgbRed;
					uiDWORD clr = MAKE_RGB(pbi->bmiColors[idx].rgbBlue,pbi->bmiColors[idx].rgbGreen,pbi->bmiColors[idx].rgbRed);
					
					if (clr == aMaskClr&&aMaskClr != 1)
					{
						argb[k++] = 0;//MAKECOLOR(0,pbi->bmiColors[idx].rgbBlue,pbi->bmiColors[idx].rgbGreen,pbi->bmiColors[idx].rgbRed);				
					}
					else
					{
						argb[k++] = MAKECOLOR(0xFF,pbi->bmiColors[idx].rgbRed,pbi->bmiColors[idx].rgbGreen,pbi->bmiColors[idx].rgbBlue);		
					}
				}
				index -= pitch;
			}
		}
		else if(bih.biBitCount == 24)
		{
			int k=0;
			int i,j;
			int index = (bih.biHeight-1)*pitch;
			int t=0;
			
			// »Áπ˚—⁄¥a…´ûÈ0£¨ƒ«√¥»°◊Û…œΩ«µ⁄“ªÇÄœÒÀÿµƒÓÅ…´◊˜ûÈ—⁄¥a…´°£
			// ÷ÆÀ˘“‘◊ˆﬂ@ÇÄ‘O”ãºÉ¥‚ «“ÚûÈ∑≈¥Û¬∑ø⁄º˝Ó^àD∆¨µƒµ◊…´≤ª»´ «0xFF00FFåß÷¬
			if(aMaskClr==0)
			{
				aMaskClr = MAKE_RGB(aBmpStream[index+2],aBmpStream[index+1],aBmpStream[index]);
			}
			
			for(i=0; i<bih.biHeight; i++)
			{
				for(j=0,t=0; j<bih.biWidth; j++, t+=3)
				{
					// 					aOutPut24->iBgr[k++] = aBmpStream[index+t];
					// 					aOutPut24->iBgr[k++] = aBmpStream[index+t+1];
					// 					aOutPut24->iBgr[k++] = aBmpStream[index+t+2];
					uiDWORD clr = MAKE_RGB(aBmpStream[index+t+ 2],aBmpStream[index+t+1],aBmpStream[index+t+0]);
					if (clr == aMaskClr&&aMaskClr != 1)
					{
						argb[k++] = 0;//MAKECOLOR(0,aBmpStream[index+t],aBmpStream[index+t+1],aBmpStream[index+t+2]);				
					}
					else
					{
						argb[k++] = MAKECOLOR(0xFF,aBmpStream[index+t+2],aBmpStream[index+t+1],aBmpStream[index+t+0]);		
					}
				}
				index -= pitch;
			}
		}
		else if(bih.biBitCount == 16)
		{
			uiBYTE r,g,b;
			int i,j;
			int k=0;
			int t=0;
			int index = (bih.biHeight-1)*pitch;
			uiWORD clr555=0;	// 16ŒªBMPŒƒº˛µƒ—’…´÷µ «555∏Ò Ω
			uiDWORD dwMask[4] = {0x00007c00, 0x000003e0, 0x0000001f, 0x00000000};
			
			if(bih.biCompression != 0L)//BI_RGB)
			{
				memcpy(dwMask, aBmpStream, sizeof(uiDWORD)*4);
				aBmpStream += sizeof(uiDWORD)*4;
			}
			
			// »Áπ˚—⁄¥a…´ûÈ0£¨ƒ«√¥»°◊Û…œΩ«µ⁄“ªÇÄœÒÀÿµƒÓÅ…´◊˜ûÈ—⁄¥a…´°£
			// ÷ÆÀ˘“‘◊ˆﬂ@ÇÄ‘O”ãºÉ¥‚ «“ÚûÈ∑≈¥Û¬∑ø⁄º˝Ó^àD∆¨µƒµ◊…´≤ª»´ «0xFF00FFåß÷¬
			if(aMaskClr==0)
			{
				clr555 = MAKEWORD(aBmpStream[index+1],aBmpStream[index]);
				b = _555R(clr555);
				g = _555G(clr555);
				r = _555B(clr555);
				aMaskClr = MAKE_RGB(b,g,r);
			}
			
			for(i=0; i<bih.biHeight; i++)
			{
				for(j=0,t=0; j<bih.biWidth; j++,t+=2)
				{
					clr555 = MAKEWORD(aBmpStream[index+t+1],aBmpStream[index+t]);
					b = _555R(clr555);
					g = _555G(clr555);
					r = _555B(clr555);
					// 					aOutPut24->iBgr[k++] = b;
					// 					aOutPut24->iBgr[k++] = g;
					// 					aOutPut24->iBgr[k++] = r;
					uiDWORD clr = MAKE_RGB(b,g,r);
					if (clr == aMaskClr&&aMaskClr != 1)
					{
						argb[k++] = 0;//MAKECOLOR(0,b,g,r);				
					}
					else
					{
						
						argb[k++] = MAKECOLOR(0xFF,b,g,r);	
						
						
					}
				}
				index -= pitch;
			}
		}
	}
	
	return argb;
}

uiDWORD* LoadBMP565(uiBYTE* aBmpStream, int aBytes ,uiBYTE * alpha)
{
    uiBYTE r,g,b;
    uiWORD clr565=0;	// 16ŒªBMPŒƒº˛µƒ—’…´÷µ «555∏Ò Ω
    //uiDWORD dwMask[4] = {0x00007c00, 0x000003e0, 0x0000001f, 0x00000000};
    int bufsize = aBytes*2;
    uiDWORD *argb = (uiDWORD*)malloc(bufsize);

    
    // »Áπ˚—⁄¥a…´ûÈ0£¨ƒ«√¥»°◊Û…œΩ«µ⁄“ªÇÄœÒÀÿµƒÓÅ…´◊˜ûÈ—⁄¥a…´°£
    // ÷ÆÀ˘“‘◊ˆﬂ@ÇÄ‘O”ãºÉ¥‚ «“ÚûÈ∑≈¥Û¬∑ø⁄º˝Ó^àD∆¨µƒµ◊…´≤ª»´ «0xFF00FFåß÷¬
    int pixIndex = 0;
    int i = 0;
    for (i = 0,pixIndex = 0; i < aBytes; i+=2,pixIndex++)
    {
        clr565 = MAKEWORD(aBmpStream[i+1],aBmpStream[i]);
        b = _565B(clr565);
        g = _565G(clr565);
        r = _565R(clr565);
        argb[pixIndex] = MAKECOLOR(alpha[pixIndex]<<3,b,g,r);
    }
//    for (pixIndex = 0; pixIndex < aBytes/2; pixIndex++)
//    {
//        printf("%d\n",alpha[pixIndex]);
//    }
    return argb;
//    for(i=0; i<bih.biHeight; i++)
//    {
//        for(j=0,t=0; j<bih.biWidth; j++,t+=2)
//        {
//            clr555 = MAKEWORD(aBmpStream[index+t+1],aBmpStream[index+t]);
//            b = _555R(clr555);
//            g = _555G(clr555);
//            r = _555B(clr555);
//            // 					aOutPut24->iBgr[k++] = b;
//            // 					aOutPut24->iBgr[k++] = g;
//            // 					aOutPut24->iBgr[k++] = r;
//            uiDWORD clr = MAKE_RGB(b,g,r);
//            if (clr == aMaskClr&&aMaskClr != 1)
//            {
//                argb[k++] = 0;//MAKECOLOR(0,b,g,r);				
//            }
//            else
//            {
//                
//                argb[k++] = MAKECOLOR(0xFF,b,g,r);	
//                
//                
//            }
//        }
//        index -= pitch;
//    }
}

unsigned char* Convert565_888(unsigned char* aBmpStream,int nWidth,int nHeight,unsigned char * alpha)
{
    int i = 0;
    int j = 0;
    int nDepth = 0;
    int nSize = 0;
    unsigned short *pn16Src = NULL;
    unsigned char *p8Dst = NULL;
    int nIndex = 0;
    
    do {
        if ((aBmpStream == NULL) || (nWidth <= 0) || (nHeight <= 0)) {
            break;
        }
        
        
		pn16Src = (unsigned short*)aBmpStream;
		
		if (alpha != NULL)
		{
			nDepth = 4;
		}
		else
		{
			nDepth = 3;
		}
        
		nSize = nWidth * nHeight * nDepth;
        
		p8Dst = (uiBYTE*)malloc(nSize);
        
		if (p8Dst == NULL)
		{
			break;
		}
        memset(p8Dst,0,nSize);
		
		for (i = 0; i < nHeight; i++)
		{
			nIndex = i * nWidth * nDepth;
			for (j = 0; j < nWidth; j++)
			{
				if (alpha != NULL)
				{
					p8Dst[nIndex+3] = (*alpha); alpha++;
				}
				
				/* rgb */
				p8Dst[nIndex+0] = (*pn16Src & 0xF800) >> 8;
				p8Dst[nIndex+1] = (*pn16Src & 0x07E0) >> 3;
				p8Dst[nIndex+2] = (*pn16Src & 0x001F) << 3;
				pn16Src++;
				nIndex += 4;
			}
		}
    } while (0);
    return p8Dst;
}


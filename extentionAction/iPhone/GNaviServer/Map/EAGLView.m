/*
 
 File: EAGLView.m
 Abstract: Convenience class that wraps the CAEAGLLayer from CoreAnimation into a
 UIView subclass.
 
 Version: 1.6
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2008 Apple Inc. All Rights Reserved.
 
 */

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <GLKit/GLKit.h>
#import "EAGLView.h"
#import "UIDevice+Category.h"
#import <sys/time.h>
//#define LookSwapBufferTime    //开启这个宏，用于查看swapbuffer耗时，单位毫秒

static EAGLContext *_context = nil;
static GLuint					_framebuffer = 0;
static GLuint					_renderbuffer = 0;
static GLuint					_depthBuffer = 0;

static GLuint					_sampleframebuffer = 0;
static GLuint					_samplecolorbuffer = 0;
static GLuint					_sampledepthbuffer = 0;
static GLuint                   _renderTextures = 0;
static GLuint                   _program = 0;

static float textureVex[16] =
{
    -1,-1,0,0,
    1,-1,1,0,
    1,1,1,1,
    -1,1,0,1
};

//CLASS IMPLEMENTATIONS:
static float _contentScale =1.0f;	//高清参考2.0f,非高清下为1.0f
static BOOL _bAntiAliasing = NO;	//是否开启抗锯齿,IOS4以下不开启
@implementation EAGLView

@synthesize delegate=_delegate, autoresizesSurface=_autoresize, surfaceSize=_size, pixelFormat = _format, depthFormat = _depthFormat;/*, context = _context;*/

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

- (BOOL) _createSurface
{
	CAEAGLLayer*			eaglLayer = (CAEAGLLayer*)[self layer];
	CGSize					newSize;
    CGSize                  newSizePow2; //2的次方
    
	if(![EAGLContext setCurrentContext:_context])
	{
		return NO;
	}
    if (_framebuffer != 0)  //若已经创建过帧缓存，则不需要创建了
    {
        return YES;
    }
    //	eaglLayer.opaque = YES;
	newSize = [eaglLayer bounds].size;
	newSize.width = roundf(newSize.width)*_contentScale;
	newSize.height = roundf(newSize.height)*_contentScale;
    
    newSizePow2.width = [self MinPowOf2:newSize.width];
    newSizePow2.height = [self MinPowOf2:newSize.height];
	
	glGenFramebuffers(1, &_framebuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
	
	glGenRenderbuffers(1, &_renderbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
	
    
	if(![_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)eaglLayer])
	{
		return NO;
	}
	
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbuffer);
	
	if (YES == _bAntiAliasing)
	{
        //samplebuffer
        glGenFramebuffers(1, &_sampleframebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _sampleframebuffer);
        glGenRenderbuffers(1, &_samplecolorbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _samplecolorbuffer);
        glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_RGBA8_OES, newSize.width, newSize.height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _samplecolorbuffer);
        
	}
    else
    {
        glGenFramebuffers(1, &_sampleframebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _sampleframebuffer);
        
        glGenTextures(1, &_renderTextures);
        glBindTexture(GL_TEXTURE_2D, _renderTextures);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, newSizePow2.width, newSizePow2.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _renderTextures, 0);
    }
	
	if (_depthFormat)
	{
		if (YES ==_bAntiAliasing)
		{
            glGenRenderbuffers(1, &_sampledepthbuffer);
            glBindRenderbuffer(GL_RENDERBUFFER, _sampledepthbuffer);
            
		    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, _depthFormat, newSize.width, newSize.height);
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _sampledepthbuffer);
			
		}else {
			glGenRenderbuffers(1, &_depthBuffer);
			glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);
			glRenderbufferStorage(GL_RENDERBUFFER, _depthFormat, newSizePow2.width, newSizePow2.height);
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
            Guint32  status=  glCheckFramebufferStatus(GL_FRAMEBUFFER);
            if (status != (Guint32)GL_FRAMEBUFFER_COMPLETE)
            {
                printf("error\n");
            }
			
        }
		
	}
    
	_size = newSize;
    
	if(!_hasBeenCurrent)
	{
		glViewport(0, 0, newSize.width, newSize.height);
		glScissor(0, 0, newSize.width, newSize.height);
		_hasBeenCurrent = YES;
	}
    
	// Error handling here
	
	[_delegate didResizeEAGLSurfaceForView:self];
	return YES;
}

- (void)drawTriCone
{
    GLfloat vertices[] = {
        0.7f, 0.7f, 0.0f,
        0.7f, -0.7f, 0.0f,
        -0.7f, -0.7f, 0.0f,
        -0.7f, 0.7f, 0.0f,
        0.0f, 0.0f, -1.0f,
    };
    
    GLubyte indices[] = {
        0, 1, 1, 2, 2, 3, 3, 0,
        4, 0, 4, 1, 4, 2, 4, 3
    };
    
    //    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices );
    //    glEnableVertexAttribArray(_positionSlot);
    
    // Draw lines
    //
    glDrawElements(GL_LINES, sizeof(indices)/sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);
}

- (void)render
{
    if (_context == nil)
        return;
    
    glClearColor(0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Setup viewport
    //
    //    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    //
    //    //[self drawTriangle];
    //    [self drawTriCone];
    
    BOOL sign = [_context presentRenderbuffer:GL_RENDERBUFFER];
    NSLog(@"presentRenderbuffer %d",sign);
}

- (void) _destroySurface
{
	EAGLContext *oldContext = [EAGLContext currentContext];
	
	if (oldContext != _context)
		[EAGLContext setCurrentContext:_context];
	
	glDeleteRenderbuffers(1, &_renderbuffer);
	_renderbuffer = 0;
    
	glDeleteFramebuffers(1, &_framebuffer);
	_framebuffer = 0;
    
	if (YES == _bAntiAliasing)
	{
        //del sample
		glDeleteFramebuffers(1, &_sampleframebuffer);
		_sampleframebuffer =0;
        
        glDeleteRenderbuffers(1, &_samplecolorbuffer);
        _samplecolorbuffer = 0;
        
		if(_depthFormat)
		{
            glDeleteRenderbuffers(1, &_sampledepthbuffer);
            _sampledepthbuffer = 0;
        }
	}else {
        if (_samplecolorbuffer)
        {
            glDeleteRenderbuffers(1, &_samplecolorbuffer);
            _samplecolorbuffer = 0;
        }
        if (_renderTextures)
        {
            glDeleteTextures(1, &_renderTextures);
            _renderTextures = 0;
        }
        
		if(_depthFormat)
		{
			glDeleteRenderbuffers(1, &_depthBuffer);
			_depthBuffer = 0;
		}
	}
	
	if (oldContext != _context)
		[EAGLContext setCurrentContext:oldContext];
}

- (id) initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame pixelFormat:GL_RGBA8_OES depthFormat:GL_DEPTH_COMPONENT16 preserveBackbuffer:NO];
}

- (id) initWithFrame:(CGRect)frame pixelFormat:(GLuint)format
{
	return [self initWithFrame:frame pixelFormat:format depthFormat:format preserveBackbuffer:NO];
}




-(void) setmyFrame:(CGRect)newFrame
{
    CGRect currentRect = self.frame;
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) //防止ios8地图定屏,重新创建缓存
    {
        if (CGRectEqualToRect(currentRect, newFrame)) 
        {
            return;
        }
    }
    [self setBounds:CGRectMake(0.0f, 0.0f, newFrame.size.width, newFrame.size.height)];
	[self setCenter:CGPointMake(newFrame.size.width/2, newFrame.size.width/2)];
	[[self layer] setFrame:CGRectMake(0.0f, 0.0f, newFrame.size.width, newFrame.size.height)];
	[[self layer] setBounds:CGRectMake(0.0f, 0.0f, newFrame.size.width, newFrame.size.height)];
	[self setFrame:CGRectMake(0.0f, 0.0f, newFrame.size.width, newFrame.size.height)];
    [self recreateSurface];
}

- (void)recreateSurface
{
	CAEAGLLayer*			eaglLayer = (CAEAGLLayer*)[self layer];
	CGSize					newSize;
	CGSize                  newSizePow2; //2的次方
    //	eaglLayer.opaque = YES;
    
	newSize = [eaglLayer bounds].size;
	newSize.width = roundf(newSize.width)*_contentScale;
	newSize.height = roundf(newSize.height)*_contentScale;
	newSizePow2.width = [self MinPowOf2:newSize.width];
    newSizePow2.height = [self MinPowOf2:newSize.height];
    
	if(![EAGLContext setCurrentContext:_context]) {
		return;
	}
    if (UIApplicationStateBackground == [[UIApplication sharedApplication] applicationState]) {
        return;
    }
	
    if (_renderbuffer)
    {
        glDeleteRenderbuffers(1, &_renderbuffer);
        _renderbuffer = 0;
    }
	
	if (_framebuffer)
    {
        glDeleteFramebuffers(1, &_framebuffer);
        _framebuffer = 0;
    }
    
	if (YES == _bAntiAliasing)
	{
        //del sample
        if (_sampleframebuffer)
        {
            glDeleteFramebuffers(1, &_sampleframebuffer);
            _sampleframebuffer =0;
        }
		
		if (_samplecolorbuffer)
        {
            glDeleteRenderbuffers(1, &_samplecolorbuffer);
            _samplecolorbuffer = 0;
        }
        
		if(_depthFormat)
		{
            if (_sampledepthbuffer)
            {
                glDeleteRenderbuffers(1, &_sampledepthbuffer);
                _sampledepthbuffer = 0;
            }
            
        }
	}else {
        if (_samplecolorbuffer)
        {
            glDeleteRenderbuffers(1, &_samplecolorbuffer);
            _samplecolorbuffer = 0;
        }
        if (_renderTextures)
        {
            glDeleteTextures(1, &_renderTextures);
            _renderTextures = 0;
        }
		if (_depthFormat)
		{
            if (_depthBuffer) {
                glDeleteRenderbuffers(1, &_depthBuffer);
                _depthBuffer = 0;
            }
			
		}
	}
	//create
	glGenFramebuffers(1, &_framebuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
	
	glGenRenderbuffers(1, &_renderbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
	
	if(![_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)eaglLayer]) {
		glDeleteRenderbuffers(1, &_renderbuffer);
		return ;
	}
	
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbuffer);
	
	if (YES == _bAntiAliasing) {
        //create samplebuffer
        
        glGenFramebuffers(1, &_sampleframebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _sampleframebuffer);
        
        glGenRenderbuffers(1, &_samplecolorbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _samplecolorbuffer);
        
        glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_RGBA8_OES, newSize.width, newSize.height);
        
        
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _samplecolorbuffer);
		if (_depthFormat)
		{
            glGenRenderbuffers(1, &_sampledepthbuffer);
            glBindRenderbuffer(GL_RENDERBUFFER, _sampledepthbuffer);
			glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, _depthFormat, newSize.width, newSize.height);
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _sampledepthbuffer);
		}
	}else {
        
        glGenFramebuffers(1, &_sampleframebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _sampleframebuffer);
        
        glGenTextures(1, &_renderTextures);
        glBindTexture(GL_TEXTURE_2D, _renderTextures);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, newSizePow2.width, newSizePow2.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _renderTextures, 0);
        
		if (_depthFormat)
		{
			glGenRenderbuffers(1, &_depthBuffer);
			glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);
			glRenderbufferStorage(GL_RENDERBUFFER, _depthFormat, newSizePow2.width, newSizePow2.height);
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
        }
	}
	
	_size = newSize;
	
	if(!_hasBeenCurrent) {
		glViewport(0, 0, newSize.width, newSize.height);
		glScissor(0, 0, newSize.width, newSize.height);
		_hasBeenCurrent = YES;
	}
	glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
}

- (id) initWithFrame:(CGRect)frame pixelFormat:(GLuint)format depthFormat:(GLuint)depth preserveBackbuffer:(BOOL)retained
{
	if((self = [super initWithFrame:frame]))
	{
        NSString *osName = [UIDevice getDeviceAndOSInfo];  //iphone4，newpad不需要反走样，要不然很卡，产品定义
        if ([osName isEqualToString:@"iPhone3,1"] || [osName isEqualToString:@"iPhone3,2"] || [osName isEqualToString:@"iPhone3,3"] || [osName isEqualToString:@"iPad3,1"] || [osName isEqualToString:@"iPad3,2"] || [osName isEqualToString:@"iPad3,3"])
        {
            _bAntiAliasing = NO;
        }
		else
        {
            _bAntiAliasing = YES;
        }
		if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)]) {
			_contentScale = [[UIScreen mainScreen] scale];
			self.contentScaleFactor = _contentScale;
		}
		
		CAEAGLLayer*			eaglLayer = (CAEAGLLayer*)[self layer];
		if (YES == _bAntiAliasing)
		{
            self.layer.contentsScale = _contentScale;
            
        }
        
        // CALayer 默认是透明的，必须将它设为不透明才能让其可见
        eaglLayer.opaque = YES;
        
        // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
		_format = format;
		_depthFormat = depth;
        if (nil==_context)
        {
            _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
            //多个context需采用共享方式
        }
        
		if(_context == nil)
		{
			[self release];
			return nil;
		}
		
		if(![self _createSurface])
		{
			[self release];
			return nil;
		}
        if (!_bAntiAliasing)  //创建shader
        {
            [self loadShaders];
        }
	}
    
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (void) layoutSubviews
{
	CGRect				bound = [self bounds];
	if(_autoresize && ((roundf(bound.size.width) != _size.width) || (roundf(bound.size.height) != _size.height))) {
		NSLog(@"!!!!!!!!!!resize,bounds: w=%f,h=%f ",bound.size.width,bound.size.height);
		[self _destroySurface];
		[self _createSurface];
		glFlush();
	}
    
    //	[_context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void) setAutoresizesEAGLSurface:(BOOL)autoresizesEAGLSurface;
{
	_autoresize = autoresizesEAGLSurface;
	if(_autoresize)
        [self layoutSubviews];
}

- (void) setCurrentContext
{
	if(![EAGLContext setCurrentContext:_context]) {
		printf("Failed to set current context %p in %s\n", _context, __FUNCTION__);
	}
}

- (BOOL) isCurrentContext
{
	return ([EAGLContext currentContext] == _context ? YES : NO);
}

- (void) clearCurrentContext
{
	if(![EAGLContext setCurrentContext:nil])
		printf("Failed to clear current context in %s\n", __FUNCTION__);
}

void releaseProviderBuffer(void *info, const void *data,size_t size)
{
    free((void*)data);
}


-(UIImage *) glToUIImage
{
    CAEAGLLayer*			eaglLayer = (CAEAGLLayer*)[self layer];
    CGSize newSize;
    newSize = [eaglLayer bounds].size;
	newSize.width = roundf(newSize.width)*_contentScale;
	newSize.height = roundf(newSize.height)*_contentScale;
    int height = (int)newSize.height;
    int width = (int)newSize.width ;
    //    int height = (int)self.frame.size.height*_contentScale;
    //    int width = (int)self.frame.size.width*_contentScale;
    NSInteger myDataLength = width * height * 4;
    
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    
    EAGLContext *oldContext = [EAGLContext currentContext];
    if(oldContext != _context)
        [EAGLContext setCurrentContext:_context];
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, _framebuffer);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    glBindFramebuffer(GL_FRAMEBUFFER,_sampleframebuffer);
    if(oldContext != _context)
        [EAGLContext setCurrentContext:oldContext];
    
    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
    for(int y = 0; y <height; y++)
    {
        for(int x = 0; x <width * 4; x+=4)
        {
            buffer2[(height - 1 - y) * width * 4 + x] = buffer[y * 4 * width + x];
            buffer2[(height - 1 - y) * width * 4 + x + 1] = buffer[y * 4 * width + x + 1];
            buffer2[(height - 1 - y) * width * 4 + x + 2] = buffer[y * 4 * width + x + 2];
            buffer2[(height - 1 - y) * width * 4 + x + 3] = buffer[y * 4 * width + x + 3];
        }
    }
    // make data provider with data.
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, releaseProviderBuffer);
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    // then make the uiimage from that
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    free(buffer);
    
    return myImage;
    
}

//若有多个opengles同时绘制，需要调用此接口，重新把缓存绑定过来
-(void)bindBuffer
{
    if (UIApplicationStateBackground == [[UIApplication sharedApplication] applicationState] ) {
        return;
    }
    glFlush();
    [self recreateSurface];
}
//利用双缓冲，先将图画到一个context上，然后交换当前context和画好的，这样避免屏幕闪烁，两个帧缓存对象。一个是主缓存，用于最后的显示；另一个就是用于多重采样的缓存。我们之前说过，多重采样需要有多个颜色、深度和模板信息。我们在绘制时应该在多重采样帧缓存中绘制，最后将该缓存的内容拷贝到显示帧缓存用于显示
- (void) swapBuffers
{
    if (UIApplicationStateBackground == [[UIApplication sharedApplication] applicationState]) {
        return;
    }
    int value = [[MWPreference sharedInstance] getValue:PREF_BACKGROUND_MODE];  //后台模式不刷图
    if (value == 1)
    {
        return;
    }
#ifdef LookSwapBufferTime
    Guint64 t;
    struct timeval tv_begin;
    gettimeofday(&tv_begin, NULL);
    t = (Guint64)1000000 * (tv_begin.tv_sec) + tv_begin.tv_usec;
    Guint32 uTickCount = (Guint32)(t / 1000);
    Guint32 time = uTickCount;
#endif
    glFlush();
    [EAGLContext setCurrentContext:_context];//设为当前画布
	if (YES == _bAntiAliasing) //renderbuf多重采样 然后进行抗锯齿效果
	{
	    glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, _framebuffer);    // 绑定绘制桢缓冲区
	    glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, _sampleframebuffer);// 绑定采样桢缓冲区
        glResolveMultisampleFramebufferAPPLE();//将多重采样帧缓存的内容拷贝到显示帧缓存
        
	    const GLenum discards[] = {GL_COLOR_ATTACHMENT0,GL_DEPTH_ATTACHMENT};
        glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE,2,discards);//清除GL_READ_FRAMEBUFFER_APPLE缓存里的2个渲染缓存，色彩和深度渲染缓存
        glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);// 绑定当前绘制缓存为显示绘制缓存
	    // 渲染到设备
        if(![_context presentRenderbuffer:GL_RENDERBUFFER])
        {
			printf("Failed to swap renderbuffer in %s\n", __FUNCTION__);
		}
	    glBindFramebuffer(GL_FRAMEBUFFER,_sampleframebuffer);//绑定当前帧缓存为显示帧缓存
	}
    else
	{
        glBindFramebuffer(GL_FRAMEBUFFER,_framebuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
        
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_BLEND);
        glUseProgram(_program);
        glBindTexture(GL_TEXTURE_2D, _renderTextures);
        glEnableVertexAttribArray(0);
        glEnableVertexAttribArray(1);
        glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 16, &textureVex[0]);
		glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 16, &textureVex[2]);
        
        glViewport(0, 0, [self MinPowOf2:self.bounds.size.width* SCALE],[self MinPowOf2:self.bounds.size.height* SCALE]);
        glClearColor(1.0f, 0.0f, 0.0f, 1.0f);
        glClearDepthf(1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
        
        const GLenum discards[] = {GL_DEPTH_ATTACHMENT};
        glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE,1,discards);//清除GL_READ_FRAMEBUFFER_APPLE缓存里的2个渲染缓存，色彩和深度渲染缓存
        
		if(![_context presentRenderbuffer:GL_RENDERBUFFER])
        {
			printf("Failed to swap renderbuffer in %s\n", __FUNCTION__);
		}
        glBindFramebuffer(GL_FRAMEBUFFER,_sampleframebuffer);//绑定当前帧缓存为显示帧缓存
	}
    
#ifdef LookSwapBufferTime
    Guint64 t1;
    struct timeval tv_begin1;
    gettimeofday(&tv_begin1, NULL);
    t1 = (Guint64)1000000 * (tv_begin1.tv_sec) + tv_begin1.tv_usec;
    Guint32 uTickCount1 = (Guint32)(t1 / 1000);
    Guint32 time1 = uTickCount1;
    printf("swapbuffer time : %d\n",time1 - time);
#endif
}

+ (UIImage *) snapshot:(EAGLView *)eaglview
{
    NSInteger x = 0;
    NSInteger y = 0;
    NSInteger width = eaglview.frame.size.width;
    NSInteger height = eaglview.frame.size.width;
    NSInteger dataLength = width * height * 4;
	
	// Need to do this to get it to flush before taking the snapshit
	//
    NSUInteger i;
    for ( i=0; i<100; i++ )
	{
        glFlush();
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, (float)1.0/(float)60.0, FALSE);
	}
	
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
	
    // Read pixel data from the framebuffer
    //
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(x, y, width, height, GL_RGBA8_OES, GL_UNSIGNED_BYTE, data);
	
    // Create a CGImage with the pixel data
    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
    // otherwise, use kCGImageAlphaPremultipliedLast
    //
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast, ref, NULL, true, kCGRenderingIntentDefault);
	
    // OpenGL ES measures data in PIXELS
    // Create a graphics context with the target size measured in POINTS
    //
    NSInteger widthInPoints;
    NSInteger heightInPoints;
	
    if (NULL != UIGraphicsBeginImageContextWithOptions)
	{
        // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
        // Set the scale parameter to your OpenGL ES view's contentScaleFactor
        // so that you get a high-resolution snapshot when its value is greater than 1.0
        //
        CGFloat scale = eaglview.contentScaleFactor;
        widthInPoints = width / scale;
        heightInPoints = height / scale;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
	}
    else
	{
        // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
        //
        widthInPoints = width;
        heightInPoints = height;
        UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
	}
	
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
	
    // UIKit coordinate system is upside down to GL/Quartz coordinate system
    // Flip the CGImage by rendering it to the flipped bitmap context
    // The size of the destination area is measured in POINTS
    //
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
	
    // Retrieve the UIImage from the current context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();   // autoreleased image
	
    UIGraphicsEndImageContext();
	
    // Clean up
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);
    
    return image;
}

- (CGPoint) convertPointFromViewToSurface:(CGPoint)point
{
	CGRect				bounds = [self bounds];
	
	return CGPointMake((point.x - bounds.origin.x) / bounds.size.width * _size.width, (point.y - bounds.origin.y) / bounds.size.height * _size.height);
}

- (CGRect) convertRectFromViewToSurface:(CGRect)rect
{
	CGRect				bounds = [self bounds];
	
	return CGRectMake((rect.origin.x - bounds.origin.x) / bounds.size.width * _size.width, (rect.origin.y - bounds.origin.y) / bounds.size.height * _size.height, rect.size.width / bounds.size.width * _size.width, rect.size.height / bounds.size.height * _size.height);
}

#pragma mark -  OpenGL ES 2 shader compilation

//求最小2的n次方
- (Gint32)MinPowOf2:(Gint32)a
{
    Gint32 rval = 1;/* 返回值*/
    
    /* 循环除于*/
    while(rval < a)
    {
        rval<<= 1;
    }/* 返回*/
    return(rval);
}

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, 0, "position");
    glBindAttribLocation(_program, 1, "TexCoordIn");
    
    
    //    glBindAttribLocation(_program, NUM_ATTRIBUTES, "TexCoordIn");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}
@end

//
//  Plugin_DataVerify_UncompressController.m
//  plugin_DataVerify
//
//  Created by yi yang on 11-11-28.
//  Copyright 2011年 autonavi.com. All rights reserved.
//

#import "Plugin_DataVerifyUncompressController.h"
#import "ZipArchive.h"
#import "Plugin_DataVerify_Globall.h"
#import <sys/param.h>
#import <sys/mount.h>
#import "GDBL_DataVerify.h"
#import "Plugin_DataVerifyDelegate.h"
#import "VCTranslucentBarButtonItem.h"
#import "ANParamValue.h"
#import "GDSkinColor.h"
#import "MWSkinDownloadManager.h"



@implementation Plugin_DataVerifyUncompressController

@synthesize lblContent,lblIndex,activityWaiting;//,btnQuit;

-(id)initWithFileList:(NSArray*)uncompressFiles ZipTodestPath:(NSString*)zipTodestPath DataVerityType:(int)verityType
{
    self =[super init];
    if (self) {
        [ANParamValue sharedInstance].bSupportAutorate = YES;
       
        
        currentFileList = [[NSMutableArray alloc]initWithArray:uncompressFiles];

        failFileList =[[NSMutableArray alloc]init];
        if (zipTodestPath) {
            zipDestPath=[[NSString alloc] initWithString:zipTodestPath];
        }
        zipIdx =0;
        
        dataVerityType = verityType;
       
        
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
     self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.title = STR(@"CityDownloadManage_mapDataUnzip", Localize_CityDownloadManage);
    
    
    imageViewLabelBac = [[UIImageView alloc] init];
    [imageViewLabelBac setImage:[IMAGE(@"unzipBac.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:20. topCapHeight:20.]];
    [self.view addSubview:imageViewLabelBac];
    [imageViewLabelBac release];
    
    if (88.0f == IPHONE5_OFFSET)
    {
        lblContent= [[[UILabel alloc] initWithFrame:CGRectMake(00.0f, 10.0f, 320.0f, 50.0f)]autorelease];
    }
    else
    {
        lblContent= [[[UILabel alloc] initWithFrame:CGRectMake(00.0f, 10.0f, 320.0f, 60.0f)]autorelease];
    }

	lblContent.textAlignment = UITextAlignmentCenter;
	lblContent.backgroundColor = [UIColor clearColor];
	lblContent.textColor = [UIColor whiteColor]; 
	lblContent.font = [UIFont fontWithName:[[UIFont familyNames] objectAtIndex:7] size:18];
    [self.view addSubview:lblContent];
    
    lblIndex= [[[UILabel alloc] initWithFrame:CGRectMake(80.0f, 40.0f, 160, 60)] autorelease];
	lblIndex.textAlignment = UITextAlignmentCenter;
	lblIndex.backgroundColor = [UIColor clearColor];
	lblIndex.textColor = [UIColor whiteColor]; 
	lblIndex.font = [UIFont fontWithName:[[UIFont familyNames] objectAtIndex:7] size:18];
    [lblIndex setText:@""];
    [self.view addSubview:lblIndex];
    
    [self create_UIActivityIndView:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:activityWaiting];
    [activityWaiting release];
    [activityWaiting startAnimating];
    
    quitUnCompress = NO;
    isFinish = NO;
    isCompressFail = NO;
    
    if (GD_ER_DATAUNCOMPRESS == dataVerityType) { //解压数据
        if (currentFileList && [currentFileList count] > 0) {
            [self unZipFiles];
            
            [lblContent setText:STR(@"CityDownloadManage_dataUnziping", Localize_CityDownloadManage)];
            
        }
    }
    
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    if (Interface_Flag == 0)
	{
		[self changePortraitControlFrameWithImage];
	}
	else if(Interface_Flag == 1)
	{
		[self changeLandscapeControlFrameWithImage];
	}
}


- (void)viewDidUnload
{
    currentFileList =nil;
    failFileList = nil;
    zipDestPath =nil; 
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)changePortraitControlFrameWithImage
{
    if (isPad) {
        [imageViewLabelBac setFrame:CGRectMake(0., 0., APPWIDTH-224., 120.)];
        [imageViewLabelBac setCenter:CGPointMake(APPWIDTH/2.0, 120.)];
        
        if (currentFileList && [currentFileList count] > 0) {
            [lblContent setCenter:CGPointMake(APPWIDTH/2.0, 110.0)];
        }
        else{
            [lblContent setCenter:CGPointMake(APPWIDTH/2.0, 125.0)];
        }
        [lblIndex setCenter:CGPointMake(APPWIDTH/2.0, 150.0)];
        [activityWaiting setCenter:CGPointMake(APPWIDTH/2.0, 210.0)];
        UIImage *image = IMAGE(@"pcd_tip_iPad.jpg", IMAGEPATH_TYPE_1);
        self.view.layer.contents = (id) image.CGImage;
    }
    else{
        [imageViewLabelBac setFrame:CGRectMake(0., 0., APPWIDTH-44., 85.)];
        [imageViewLabelBac setCenter:CGPointMake(APPWIDTH/2.0, 50.)];
        
        if (currentFileList && [currentFileList count] > 0) {
            [lblContent setFrame:CGRectMake(0.0, 10.0, APPWIDTH, 70.0)];
        }
        else{
            [lblContent setFrame:CGRectMake(0.0, 15.0, APPWIDTH, 70.0)];
        }
        [lblIndex setCenter:CGPointMake(APPWIDTH/2.0, 72.0)];
        [activityWaiting setCenter:CGPointMake(APPWIDTH/2.0, 120.0)];
        UIImage *image = IMAGE(@"pcd_tip.jpg", IMAGEPATH_TYPE_1);
        self.view.layer.contents = (id) image.CGImage;
    }
    
}
- (void)changeLandscapeControlFrameWithImage
{
    if (isPad) {
        [imageViewLabelBac setFrame:CGRectMake(0., 0., APPHEIGHT-480., 120.)];
        [imageViewLabelBac setCenter:CGPointMake(APPHEIGHT/2.0, 100.)];
        
        if (currentFileList && [currentFileList count] > 0) {
            [lblContent setCenter:CGPointMake(APPHEIGHT/2.0, 90.0)];
        }
        else{
            [lblContent setCenter:CGPointMake(APPHEIGHT/2.0, 105.0)];
        }
        [lblIndex setCenter:CGPointMake(APPHEIGHT/2.0, 130.0)];
        [activityWaiting setCenter:CGPointMake(APPHEIGHT/2.0, 185.0)];
        UIImage *image = IMAGE(@"h_pcd_tip_iPad.jpg", IMAGEPATH_TYPE_1);
        self.view.layer.contents = (id) image.CGImage;
    }
    else{
        [imageViewLabelBac setFrame:CGRectMake(0., 0., APPHEIGHT-210., 85.)];
        [imageViewLabelBac setCenter:CGPointMake(APPHEIGHT/2.0, 50.)];
        
        if (currentFileList && [currentFileList count] > 0) {
            [lblContent setFrame:CGRectMake(0.0, 10.0, APPHEIGHT, 60.0)];
        }
        else{
            [lblContent setFrame:CGRectMake(0.0, 20.0, APPHEIGHT, 60.0)];
        }
        [lblIndex setCenter:CGPointMake(APPHEIGHT/2.0, 70.0)];
        [activityWaiting setCenter:CGPointMake(APPHEIGHT/2.0, 100.0)];
        UIImage *image = IMAGE(@"h_pcd_tip.jpg", IMAGEPATH_TYPE_1);
        self.view.layer.contents = (id) image.CGImage;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
        
        [self changeLandscapeControlFrameWithImage];
	}
	else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        
        [self changePortraitControlFrameWithImage];
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (!OrientationSwitch)
	{
        return (Orientation == interfaceOrientation);
	}
	
	return  YES;
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return  UIInterfaceOrientationMaskAll;
}
-(void) dealloc
{
    if (currentFileList) {
        [currentFileList release];
        currentFileList = nil;
    }
    if (failFileList) {
        [failFileList release];
        failFileList = nil;
    }
    if (zipDestPath) {
        [zipDestPath release];
        zipDestPath = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];

}

#pragma mark private 内部方法

-(void)unZipFiles
{
    if (isCompressFail) {
        isCompressFail = NO;

        return;

    }
    if (quitUnCompress) {
        [self.navigationController popToRootViewControllerAnimated:NO];
        return;
    }
    if (zipIdx<[currentFileList count])//数据解压
    {
        [lblIndex setText:[NSString stringWithFormat:@"(%i/%i)",zipIdx+1,[currentFileList count]]];
        [NSThread detachNewThreadSelector:@selector(unZipSingleDo) toTarget:self withObject:nil];
    }else//检测是否解压成功
    {

        [lblIndex setText:@""];
		[lblContent setFrame:CGRectMake(0.0f, 0.0f, 320, 60 + IPHONE5_OFFSET)];
        if ([failFileList count]>0) {
            __block id weakself = self;
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:[NSString stringWithFormat:STR(@"CityDownloadManage_UnzipFail",Localize_CityDownloadManage),[failFileList count]]];
            
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                
                if ([activityWaiting isAnimating]) {
                    [activityWaiting stopAnimating];
                }
                NSError *error;
                for (NSString *fileName in failFileList) {
                    if([[NSFileManager defaultManager] fileExistsAtPath:fileName])
                    {
                        [[NSFileManager defaultManager] removeItemAtPath:fileName error:&error];
                    }
                }
                isFinish = YES;
                id module = [[[Plugin_DataVerifyDelegate alloc]init] autorelease];
                NSArray* param =[[NSArray alloc]initWithObjects:((ANViewController *)weakself).navigationController,[NSNumber numberWithInt:1] , nil];
                [((ANViewController *)weakself).navigationController popViewControllerAnimated:NO];
                [module enter:param];
                [param release];
                
            }];
            [alertView show];
            [alertView release];
            
            [lblContent setText:STR(@"CityDownloadManage_unzipFinish",Localize_CityDownloadManage)];	
			
			return;
        } else {
            [lblContent setText:STR(@"CityDownloadManage_unzipSuccess",Localize_CityDownloadManage)];	
			
		}

        if ([activityWaiting isAnimating]) {
            [activityWaiting stopAnimating];
        }
        isFinish = YES;
		
		id module = [[[Plugin_DataVerifyDelegate alloc]init]autorelease];
		NSArray* param =[[NSArray alloc]initWithObjects:self.navigationController,[[[NSNumber alloc]initWithInt:1] autorelease], nil];
		        
		[module enter:param];
        [param release];
       // [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void) unZipSingleDo
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self zipFileThread];
	[self performSelectorOnMainThread:@selector(singleFinish) withObject:(signed char)NO waitUntilDone:(signed char)NO];
	[pool release];
}
-(void) zipFileThread
{
//    NSString* fileName= [[currentFileList objectAtIndex:zipIdx] copy];
    singleResult=[self unCompressFile:[currentFileList objectAtIndex:zipIdx] ToDestPath:zipDestPath];
}
-(void) singleFinish
{
    if (singleResult==YES) {//当前文件解压成功，继续解压下一个文件
            
            zipIdx++;
            
            [self unZipFiles];

    }
    else//当前文件解压失败
    {
        zipFail++;
        [lblIndex setText:[NSString stringWithFormat:@"(%d/%d)",zipIdx,[currentFileList count]]];
        if (zipFail>2) {            
            zipFail =0;//reset fail times;
            [failFileList addObject:[NSString stringWithFormat:@"%@",[currentFileList objectAtIndex:zipIdx]]];

            zipIdx++;
            [self unZipFiles];

        }else
        {
            [self unZipFiles];
        }
    }
}

-(float)getCurDiskSpaceInBytes
{    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);    
    struct statfs tStats;    
    statfs([[paths lastObject] cString], &tStats);    
    float totalSpace = (float)(tStats.f_bsize * tStats.f_bfree);
    if (totalSpace > 209715200) {
        totalSpace = totalSpace - 209715200;
    }
    return totalSpace;    
}

/**解压缩文件
 *srcPath:要解压缩的文件,destpath:要解压到的位置
 */
-(BOOL) unCompressFile:(NSString*) srcPath ToDestPath:(NSString*) destPath
{
    long long disksize = [self getCurDiskSpaceInBytes];
    NSDictionary *dic = [[NSFileManager defaultManager] attributesOfItemAtPath:srcPath error:nil];
    unsigned long long  size = [dic fileSize];
    if (disksize < size*2)//空间不足，解压文件需要2倍的空间
    {
        
        [self deleteFileWithZipName:srcPath];
        isCompressFail = YES;
        GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:[NSString stringWithFormat:STR(@"CityDownloadManage_insufficientDiskSpace",Localize_CityDownloadManage),[failFileList count]]];
        
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
            
            quitUnCompress =YES;
            [[UIApplication sharedApplication] exitApplication];//退出导航
            
        }];
        [alertView show];
        [alertView release];
        
        return NO;
    }

    int result=0;//判断是否解压成功
    
    ZipArchive *za = [[ZipArchive alloc] init];
    NSLog(@"src Path:%@",srcPath);
    
    if([za UnzipOpenFile:srcPath])
    {
        
        int ret = [za getRetValue];
		if( ret!=UNZ_OK )
		{
			[za OutputErrorMessage:@"Failed"];
		}
		
		do
		{
            
			long long disksize = [self getCurDiskSpaceInBytes];
//			NSDictionary *dic = [[NSFileManager defaultManager] attributesOfItemAtPath:srcPath error:nil];
//            unsigned long long  size = [dic fileSize];
            
//            if (disksize < size) {
//                result = 1;
//                break;
//            }
			int zaResult = [za UnzipFileTo:destPath overWrite:YES retValue:&ret filesize:disksize];
			
            if (zaResult==1) 
			{
				result = zaResult;
				//[delegate exception:self exception:[NSError errorWithDomain:@"error_storage" code:41 userInfo:nil]];
				break;
			}else
            {
                result = zaResult;
            }
		}while (ret==UNZ_OK && UNZ_OK!=UNZ_END_OF_LIST_OF_FILE) ;
		
		
        [za UnzipCloseFile];
    }
    [za release];
    
    
    if (result==2) 
    {

        NSError *error;
        if([[NSFileManager defaultManager] fileExistsAtPath:srcPath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:srcPath error:&error];
        }
        if (error==nil) {
            return YES;
        }
    }        
    else if (result==1) //解压失败处理
    {
        
        [self deleteFileWithZipName:srcPath];
        
        isCompressFail = YES;
        GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:[NSString stringWithFormat:STR(@"CityDownloadManage_insufficientDiskSpace",Localize_CityDownloadManage),[failFileList count]]];
        
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
            
            quitUnCompress =YES;
            [[UIApplication sharedApplication] exitApplication];//退出导航
            
        }];
        [alertView show];
        [alertView release];
		
        return NO;
    }else
    {
        return NO;
    }
    return YES;
}

- (void)create_UIActivityIndView:(UIActivityIndicatorViewStyle)style
{
	CGRect frame;

    frame = CGRectMake(0.0, 0.0, 80, 80);
    activityWaiting = [[UIActivityIndicatorView alloc] initWithFrame:frame];
    [activityWaiting setCenter:CGPointMake(180,123)];

	activityWaiting.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[activityWaiting sizeToFit];
}

#pragma private UIAlert method

-(void) dimissAlert:(UIAlertView*)alert
{
    if (alert) {
        [alert dismissWithClickedButtonIndex:[alert firstOtherButtonIndex] animated:NO];
        [alert release];
    }
    
}

//删除解压后的文件
- (void)deleteFileWithZipName:(NSString *)string
{
    if (!string) {
        return;
    }
    
    NSString *tmpString = [string CutNSStringFromBackWard:@"/"];
    NSString *fileName = [tmpString CutToNSString:ZIPName];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",cityData_PATH,fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
}

#pragma mark - AlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
	switch (alertView.tag)
	{
        case 0:
		    switch(buttonIndex + 1)
		{
			case 1:
            {
                
            }
			    break;
			case 2:
			{
                quitUnCompress =YES;
                [self dealloc];
                [[UIApplication sharedApplication] exitApplication];//退出导航
			}
				break;
				
		}
			break;
        case 1:
		    switch(buttonIndex + 1)
		{
    
			case 1:
			{
				quitUnCompress =YES;
                [self dealloc];
                [[UIApplication sharedApplication] exitApplication];//退出导航
			}
				break;
				
		}
			break;
        case 2:
		    switch(buttonIndex + 1)
		{
			
			case 1:
			{
                if ([activityWaiting isAnimating]) {
                    [activityWaiting stopAnimating];
                }
                NSError *error;
                for (NSString *fileName in failFileList) {
                    if([[NSFileManager defaultManager] fileExistsAtPath:fileName])
                    {
                        [[NSFileManager defaultManager] removeItemAtPath:fileName error:&error];
                    }
                }
                isFinish = YES;
                id module = [[[Plugin_DataVerifyDelegate alloc]init] autorelease];
                NSArray* param =[[NSArray alloc]initWithObjects:self.navigationController,[NSNumber numberWithInt:1] , nil];
                [self.navigationController popViewControllerAnimated:NO];
                [module enter:param];
                [param release];
			}
				break;
				
		}
			break;
        
		
		default:
			break;
			
	}
}
@end

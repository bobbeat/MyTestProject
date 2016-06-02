//
//  ViewController.m
//  openExtension
//
//  Created by gaozhimin on 14-12-17.
//  Copyright (c) 2014年 autonavi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.autonavi.appgrouptestextension"];
    
    NSLog(@"app group:\n%@",containerURL.path);
    
    
    
    //打印可执行文件路径
    
    NSLog(@"bundle:\n%@",[[NSBundle mainBundle] bundlePath]);
    
    
    //打印documents
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *path = [paths objectAtIndex:0];
    NSLog(@"documents:\n%@",path);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectorAction:(id)sender
{
    NSArray *activityItems = [[NSArray alloc]initWithObjects:
                              	                              @"移动开发技术尽在DevDiv移动技术开发社区",
                              	                              @"http://www.DevDiv.com",
                              	                              [UIImage imageNamed:@"background1.png"], nil];
    
    	    // 初始化一个UIActivityViewController
    	    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:Nil];
    
    	    // 写一个bolck，用于completionHandler的初始化
    	    UIActivityViewControllerCompletionHandler myBlock = ^(NSString *activityType,BOOL completed) {
                NSLog(@"%@", activityType);
        	        if(completed) {
            	            NSLog(@"completed");
            	        } else
                	        {
                    	            NSLog(@"cancled");
                    	        }
        	        [activityVC dismissViewControllerAnimated:YES completion:Nil];
        	    };
    
    	    // 初始化completionHandler，当post结束之后（无论是done还是cancell）该blog都会被调用
    	    activityVC.completionHandler = myBlock;
    
    	    // 以模态方式展现出UIActivityViewController
    	    [self presentViewController:activityVC animated:YES completion:Nil];
    
    
}
@end

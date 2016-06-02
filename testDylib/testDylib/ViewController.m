//
//  ViewController.m
//  testDylib
//
//  Created by gaozhimin on 14-8-28.
//  Copyright (c) 2014年 autonavi. All rights reserved.
//

#import "ViewController.h"
#include "dlfcn.h"
#import <objc/runtime.h> 

@implementation UIViewController (HookPortal)

-(void)myViewDidLoad
{
    NSLog(@"----------------------- myViewDidLoad ----------------------");
}

@end

typedef void(*pMytest)();

@interface ViewController ()

@end

@implementation ViewController

- (id)init
{
    self = [super init];
    if (self) {
        
        void *handle = (void*)dlopen("/Library/MobileSubstrate/DynamicLibraries/testlib.dylib", 0x2);
        void *method = dlsym(handle, "myViewDidLoad");
//        pMytest test = (void(*)())method;
        if (method) {
//            test();
            NSLog(@"++++");
        }else{
            NSLog(@"----");
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"adfaf");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


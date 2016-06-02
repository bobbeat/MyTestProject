//
//  ViewController.m
//  memorytest
//
//  Created by gaozhimin on 15/7/1.
//  Copyright (c) 2015年 autonavi. All rights reserved.
//

#import "ViewController.h"
#include <sys/sysctl.h>
#include <mach/mach.h>

#define maxmalloc 500
#define another 1

int *anotherInt[another];

@interface ViewController ()
{
    int *mallocint[maxmalloc];
    UILabel *_memLable;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _memLable = [[UILabel alloc] init];
    _memLable.textColor = [UIColor blueColor];
    _memLable.frame = CGRectMake(0, 0, 320, 200);
    _memLable.font = [UIFont boldSystemFontOfSize:24];
    _memLable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_memLable];
    _memLable.numberOfLines = 5;
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(getMemUsed:) userInfo:nil repeats:YES];
    
    for (int i = 0; i < maxmalloc; i++)
    {
        mallocint[i] = (int*)malloc(sizeof(int)*1024*1024);
    }
    NSLog(@"finish ");
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(functionForAdd) userInfo:nil repeats:YES];
}

- (void)getMemUsed:(NSTimer *)timer
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    
    if(kernReturn != KERN_SUCCESS) {
        return;
    }
    double free = ((vm_page_size * vmStats.free_count) / 1024.0) / 1024.0;
    double active =  ((vm_page_size * vmStats.active_count) / 1024.0) / 1024.0;
    double inactive =  ((vm_page_size * vmStats.inactive_count) / 1024.0) / 1024.0;
    double wire =  ((vm_page_size * vmStats.wire_count) / 1024.0) / 1024.0;
    _memLable.text = [NSString stringWithFormat:@"使用内存大小：%f\nfree：%f\nactive：%f\ninactive：%f\nwire：%f\n",[self usedMemory],free,active,inactive,wire];
}

// 获取当前任务所占用的内存（单位：MB）
- (double)usedMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size / 1024.0 / 1024.0;
}

- (void)functionForAdd
{
    for (int i = 0; i < 10 ; i++)
    {
        UIView *view = [[UIView alloc] init];
        [self.view addSubview:view];
    }
    for (int i = 0; i < another; i++)
    {
        anotherInt[i] = (int*)malloc(sizeof(int)*1024*512);
    }
    NSLog(@"functionForAdd onece ");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"didReceiveMemoryWarning ");
}

@end

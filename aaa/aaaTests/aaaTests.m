//
//  aaaTests.m
//  aaaTests
//
//  Created by gaozhimin on 15-1-13.
//  Copyright (c) 2015年 autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface aaaTests : XCTestCase

@end

@implementation aaaTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSLog(@"setUp");
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    NSLog(@"tearDown");
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
    NSLog(@"testExample");
}

- (void)testPerformanceExample {
    
     NSLog(@"testPerformanceExample");
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

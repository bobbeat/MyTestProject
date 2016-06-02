//
//  ViewController.m
//  runtimetest
//
//  Created by gaozhimin on 15/7/31.
//  Copyright (c) 2015年 autonavi. All rights reserved.
//

#import "ViewController.h"
#include<objc/runtime.h>

@interface ClassCustomClass : NSObject
{
    NSString *varTest1;
    NSString *varTest2;
    NSString *varTest3;
}
@property (nonatomic,assign)NSString *varTest1;
@property (nonatomic,assign)NSString *varTest2;
@property (nonatomic,assign)NSString *varTest3;
- (void) fun1;
@end

@implementation ClassCustomClass
@synthesize varTest1, varTest2, varTest3;
- (void) fun1
{
    NSLog(@"CustomClass fun1");
}

- (void) fun2
{
    NSLog(@"CustomClass fun2");
}
@end

@interface ClassCustomClassOther :NSObject {
    int varTest2;
}
- (void) fun2;
@end

@implementation ClassCustomClassOther
- (void) fun2 {
    NSLog(@"fun2");
}
@end


@interface CustomClass : NSObject
{
    NSString *varTest1;
    NSString *varTest2;
    NSString *varTest3;
}
@property (nonatomic,assign)NSString *varTest1;
@property (nonatomic,assign)NSString *varTest2;
@property (nonatomic,assign)NSString *varTest3;
- (void) fun1;
@end

@implementation CustomClass
@synthesize varTest1, varTest2, varTest3;
- (void) fun1
{
    NSLog(@"CustomClass fun1");
}

- (void) fun2
{
    NSLog(@"CustomClass fun2");
}
@end

@interface TestClass : NSObject
@end
@implementation TestClass

- (void) fun2
{
    NSLog(@"TestClass fun2");
}

@end


@interface ViewController (){
    float myFloat;
    ClassCustomClass *allobj;
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    myFloat = 2.34f;
    
    [self copyObj];
    [self setClassTest];
    [self getClassTest];
    [self getClassName];
    [self oneParam];
    [self twoParam];
//    [self objectDispose];
    [self getClassAllMethod];
    [self propertyNameList];
    [self getInstanceVar];
    [self setInstanceVar];
    [self getVarType];
    
    allobj = [ClassCustomClass new];
    allobj.varTest1 =@"varTest1String";
    allobj.varTest2 =@"varTest2String";
    allobj.varTest3 =@"varTest3String";
    NSString *str = [self nameOfInstance:@"varTest1String"];
    NSLog(@"str:%@", str);
    
    [self methodExchange];
    NSLog(@"str:%@", [str lowercaseString]);
    
    [self methodSetImplementation];
    [self justLog2];
    
    [self replaceMethod];
    NSString *temp = [@"ADbffb" uppercaseString];
    NSArray *array = [@"a11111s a22222222" componentsSeparatedByString:@" "];
    BOOL sign = [@"a" isEqualToString:@"a"];
    
    NSLog(@"string %@",[array objectAtIndex:0]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) copyObj
{
    CustomClass *obj = [CustomClass new];
    NSLog(@"%p", &obj);
    
    id objTest = object_copy(obj,sizeof(obj));
    NSLog(@"%p", &objTest);
    
    [objTest fun1];
}

- (void) objectDispose
{
    CustomClass *obj = [CustomClass new];
    object_dispose(obj);
    
    [obj release];
}

- (void) setClassTest
{
    CustomClass *obj = [CustomClass new];
    [obj fun1];
    
    Class aClass =object_setClass(obj, [TestClass class]);
    //obj 对象的类被更改了    swap the isa to an isa
    NSLog(@"aClass:%@",NSStringFromClass(aClass));
    NSLog(@"obj class:%@",NSStringFromClass([obj class]));
    [obj fun2];
}
- (void) getClassTest
{
    CustomClass *obj = [CustomClass new];
    Class aLogClass =object_getClass(obj);
    NSLog(@"%@",NSStringFromClass(aLogClass));
}

- (void) getClassName
{
    CustomClass *obj = [CustomClass new];
    NSString *className = [NSString stringWithCString:object_getClassName(obj)encoding:NSUTF8StringEncoding];
    NSLog(@"className:%@", className);
}

int cfunction(id self, SEL _cmd, NSString *str) {
    NSLog(@"%@", str);
    return 10;//随便返回个值
}

- (void) oneParam {
    
    TestClass *instance = [[TestClass alloc]init];
    //    方法添加
    class_addMethod([TestClass class],@selector(ocMethod:), (IMP)cfunction,"i@:@");
    
    if ([instance respondsToSelector:@selector(ocMethod:)]) {
        NSLog(@"Yes, instance respondsToSelector:@selector(ocMethod:)");
    } else
    {
        NSLog(@"Sorry");
    }
    
    int a = (int)[instance ocMethod:@"我是一个OC的method，C函数实现"];
    NSLog(@"a:%d", a);
}

/**
 * 两个参数
 *
 */

int cfunctionA(id self, SEL _cmd, NSString *str, NSString *str1) {
    NSLog(@"%@-%@", str, str1);
    return 20;//随便返回个值
}

- (void) twoParam {
    
    TestClass *instance = [[TestClass alloc]init];
    
    class_addMethod([TestClass class],@selector(ocMethodA::), (IMP)cfunctionA,"i@:@@");
    
    if ([instance respondsToSelector:@selector(ocMethodA::)]) {
        NSLog(@"Yes, instance respondsToSelector:@selector(ocMethodA::)");
    } else
    {
        NSLog(@"Sorry");
    }
    
    int a = (int)[instance ocMethodA:@"我是一个OC的method，C函数实现" :@"-----我是第二个参数"];
    NSLog(@"a:%d", a);
}

- (void) getClassAllMethod
{
    u_int count;
    Method* methods= class_copyMethodList([ClassCustomClass class], &count);
    for (int i = 0; i < count ; i++)
    {
        SEL name = method_getName(methods[i]);
        NSString *strName = [NSString stringWithCString:sel_getName(name)encoding:NSUTF8StringEncoding];
        NSLog(@"method = %@",strName);
    }
    free(methods);
}

- (void) propertyNameList
{
    u_int count;
    objc_property_t *properties=class_copyPropertyList([ClassCustomClass class], &count);
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName =property_getName(properties[i]);
        NSString *strName = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        NSLog(@"property = %@",strName);
    }
    free(properties);
}

//获取全局变量的值   （myFloat 为类的一个属性变量）
- (void) getInstanceVar {
    float myFloatValue;
    object_getInstanceVariable(self,"myFloat", (void*)&myFloatValue);
    NSLog(@"%f", myFloatValue);
}
//设置全局变量的值
- (void) setInstanceVar {
    float newValue = 10.00f;
    unsigned long addr = (unsigned long)&newValue;
    object_setInstanceVariable(self,"myFloat", *(float**)addr);
    NSLog(@"%f", myFloat);
}

//9、判断类的某个属性的类型
- (void) getVarType {
    ClassCustomClass *obj = [ClassCustomClass new];
    Ivar var = class_getInstanceVariable(object_getClass(obj),"varTest1");
    const char* typeEncoding =ivar_getTypeEncoding(var);
    NSString *stringType =  [NSString stringWithCString:typeEncoding encoding:NSUTF8StringEncoding];
    
    if ([stringType hasPrefix:@"@"]) {
        // handle class case
        NSLog(@"handle class case");
    } else if ([stringType hasPrefix:@"i"]) {
        // handle int case
        NSLog(@"handle int case");
    } else if ([stringType hasPrefix:@"f"]) {
        // handle float case
        NSLog(@"handle float case");
    } else
    {
        
    }
}

//10、通过属性的值来获取其属性的名字（反射机制）
- (NSString *)nameOfInstance:(id)instance
{
    unsigned int numIvars =0;
    NSString *key=nil;
    
    //Describes the instance variables declared by a class.
    Ivar * ivars = class_copyIvarList([ClassCustomClass class], &numIvars);
    
    for(int i = 0; i < numIvars; i++) {
        Ivar thisIvar = ivars[i];
        
        const char *type =ivar_getTypeEncoding(thisIvar);
        NSString *stringType =  [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        NSLog(@"ivarname = %s",ivar_getName(thisIvar));
        //不是class就跳过
        if (![stringType hasPrefix:@"@"]) {
            continue;
        }
        
        //Reads the value of an instance variable in an object. object_getIvar这个方法中，当遇到非objective-c对象时，并直接crash
        if ((object_getIvar(allobj, thisIvar) == instance)) {
            // Returns the name of an instance variable.
            key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
            break;
        }
    }
    free(ivars);
    return key;
}
//11、系统类的方法实现部分替换
- (void) methodExchange {
    Method m1 = class_getInstanceMethod([NSString class],@selector(lowercaseString));
    Method m2 = class_getInstanceMethod([NSString class],@selector(uppercaseString));
    method_exchangeImplementations(m1, m2);
    NSLog(@"%@", [@"sssAAAAss"lowercaseString]);
    NSLog(@"%@", [@"sssAAAAss"uppercaseString]);
}

//12、自定义类的方法实现部分替换
- (void) justLog1 {
    NSLog(@"justLog1");
}
- (void) justLog2 {
    NSLog(@"justLog2");
}
- (void) methodSetImplementation {
//    Method method = class_getInstanceMethod([self class],@selector(justLog1));
//    IMP originalImp = method_getImplementation(method);
//    Method m1 = class_getInstanceMethod([self class],@selector(justLog2));
//    method_setImplementation(m1, originalImp);
//    
    Method m1 = class_getInstanceMethod([self class],@selector(justLog1));
    Method m2 = class_getInstanceMethod([self class],@selector(justLog2));
    method_exchangeImplementations(m1, m2);
    NSLog(@"%@", [@"sssAAAAss"lowercaseString]);
    NSLog(@"%@", [@"sssAAAAss"uppercaseString]);
}

//typedef　cFuncPointer　　(*IMP)(id,SEL);
typedef id (*_IMP)(id, SEL, ...);

IMP cFuncPointer;
IMP cFuncPointer1;
IMP cFuncPointer2;

IMP temp;
IMP temp1;
IMP temp2;

NSString* CustomUppercaseString(id self,SEL _cmd){
    printf("真正起作用的是本函数CustomUppercaseString\r\n");
    NSString *string = cFuncPointer(self,_cmd); //(self,_cmd)
    return string;
}
NSArray* CustomComponentsSeparatedByString(id self,SEL _cmd,NSString *str){
    printf("真正起作用的是本函数CustomIsEqualToString\r\n");
    NSArray *array = cFuncPointer1(self,_cmd,str);
    return array;
}
//不起作用，求解释
BOOL CustomIsEqualToString(id self,SEL _cmd,NSString *str) {
    printf("真正起作用的是本函数CustomIsEqualToString\r\n");
    return cFuncPointer2(self,_cmd,str);
}
- (void) replaceMethod{
    cFuncPointer = class_replaceMethod([NSString class],@selector(uppercaseString), (IMP)CustomUppercaseString,"@@:");
    
    cFuncPointer1 = class_replaceMethod([NSString class],@selector(componentsSeparatedByString:), (IMP)CustomComponentsSeparatedByString,"@@:@");
    
    cFuncPointer2 = class_replaceMethod([NSString class],@selector(isEqualToString:), (IMP)CustomIsEqualToString,"B@:@");
}



@end

@interface NSObject (AutoEncodeDecode)

@end

@implementation NSObject (AutoEncodeDecode)
- (void)encodeWithCoder:(NSCoder *)encoder {
    Class cls = [self class];
    while (cls != [NSObject class]) {
        unsigned int numberOfIvars =0;
        Ivar* ivars = class_copyIvarList(cls, &numberOfIvars);
        for(const Ivar* p = ivars; p < ivars+numberOfIvars; p++){
            Ivar const ivar = *p;
            const char *type =ivar_getTypeEncoding(ivar);
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            id value = [self valueForKey:key];
            if (value) {
                switch (type[0]) {
                    case _C_STRUCT_B: {
                        NSUInteger ivarSize =0;
                        NSUInteger ivarAlignment =0;
                        NSGetSizeAndAlignment(type, &ivarSize, &ivarAlignment);
                        NSData *data = [NSData dataWithBytes:(const char *)self + ivar_getOffset(ivar)
                                                     length:ivarSize];
                        [encoder encodeObject:data forKey:key];
                    }
                        break;
                    default:
                        [encoder encodeObject:value
                                       forKey:key];
                        break;
                }
            }
        }
        free(ivars);
        cls = class_getSuperclass(cls);
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    
    if (self) {
        Class cls = [self class];
        while (cls != [NSObject class]) {
            unsigned int numberOfIvars =0;
            Ivar* ivars = class_copyIvarList(cls, &numberOfIvars);
            
            for(const Ivar* p = ivars; p < ivars+numberOfIvars; p++){
                Ivar const ivar = *p;
                const char *type =ivar_getTypeEncoding(ivar);
                NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
                id value = [decoder decodeObjectForKey:key];
                if (value) {
                    switch (type[0]) {
                        case _C_STRUCT_B: {
                            NSUInteger ivarSize =0;
                            NSUInteger ivarAlignment =0;
                            NSGetSizeAndAlignment(type, &ivarSize, &ivarAlignment);
                            NSData *data = [decoder decodeObjectForKey:key];
                            char *sourceIvarLocation = (char*)self+ivar_getOffset(ivar);
                            [data getBytes:sourceIvarLocation length:ivarSize];
                        }
                            break;
                        default:
                            [self setValue:[decoder decodeObjectForKey:key]
                                    forKey:key];
                            break;
                    }
                }
            }
            free(ivars);
            cls = class_getSuperclass(cls);
        }
    }
    
    return self;
}
@end

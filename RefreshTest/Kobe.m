//
//  Kobe.m
//  RefreshTest
//
//  Created by li  bo on 16/6/5.
//  Copyright © 2016年 li  bo. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "Kobe.h"

@implementation Kobe


- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {

        self.name = dict[@"name"];
        self.imageName = dict[@"imageName"];
        
    }
    return self;

}

+ (instancetype)KobeWithDict:(NSDictionary *)dict
{

    return [[self alloc] initWithDict:dict];

}


@end

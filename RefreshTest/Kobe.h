//
//  Kobe.h
//  RefreshTest
//
//  Created by li  bo on 16/6/5.
//  Copyright © 2016年 li  bo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Kobe : NSObject

/** 姓名 */
@property (nonatomic, copy) NSString *name;


/** 图片名 */
@property (nonatomic, copy) NSString *imageName;


/** 行号 */
@property(nonatomic, assign) NSUInteger index;

- (instancetype)initWithDict:(NSDictionary *)dict;

+ (instancetype)KobeWithDict:(NSDictionary *)dict;

@end

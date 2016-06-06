//
//  KBCell.h
//  RefreshTest
//
//  Created by li  bo on 16/6/5.
//  Copyright © 2016年 li  bo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Kobe;
@interface KBCell : UITableViewCell

/** 模型 */
@property (nonatomic, strong) Kobe *kbModel;

+ (NSString *)reuseName;

@end

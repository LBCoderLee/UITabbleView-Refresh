//
//  KBCell.m
//  RefreshTest
//
//  Created by li  bo on 16/6/5.
//  Copyright © 2016年 li  bo. All rights reserved.
//

#import "KBCell.h"
#import "Kobe.h"

@interface KBCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation KBCell

static NSString * const ID = @"kb";

- (void)awakeFromNib {

}

- (void)setKbModel:(Kobe *)kbModel
{
    _kbModel = kbModel;

    UIImage * image = [UIImage imageNamed:kbModel.imageName];
    self.iconImageView.image = [self imageWithClipImage:image borderWidth:0 boderColor:0];

    NSString *fullStr = [NSString stringWithFormat:@"%@---%zd",kbModel.name,kbModel.index];
    
    self.nameLabel.text = fullStr;

}

+ (NSString *)reuseName
{
    return ID;

}

#pragma mark - 裁剪圆形头像
- (UIImage *)imageWithClipImage:(UIImage *)image borderWidth:(CGFloat)borderW boderColor:(UIColor *)boderColor

{

    //加载image
    //UIImage *image = [UIImage imageNamed:imageName];
    //开启位图上下文

    CGSize roundSize = CGSizeMake(image.size.width + 2 * borderW, image.size.height + 2 *borderW);
    UIGraphicsBeginImageContextWithOptions(roundSize, NO, 0.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, roundSize.width,roundSize.height)];
    [boderColor set];
    [path fill];


    //设置裁剪区域

    CGRect clipRect = CGRectMake(borderW, borderW, image.size.width, image.size.height);
    path = [UIBezierPath bezierPathWithOvalInRect:clipRect];

    [path addClip];

    //绘制图片
    [image drawAtPoint:CGPointMake(borderW, borderW)];

    //从上下文中取出新的图片

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    //结束上下文
    UIGraphicsEndImageContext();
    //显示新图片
    //self.iconImageView.image = newImage;
    
    return newImage;
    
}

@end

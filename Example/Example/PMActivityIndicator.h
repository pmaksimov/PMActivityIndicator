//
//  PMActivityIndicator.h
//  CoreAnimation
//
//  Created by Pavel Maksimov on 8/29/16.
//  Copyright © 2016 Pavel Maksimov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMActivityIndicator : UIView

@property (nonatomic) CGFloat duration;
@property (nonatomic) CGFloat radius;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic) BOOL blurEnabled;
@property (nonatomic) BOOL bounceEnabled;

- (void)show;
- (void)hide;

@end

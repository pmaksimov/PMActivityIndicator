//
//  PMActivityIndicator.m
//  CoreAnimation
//
//  Created by Pavel Maksimov on 8/29/16.
//  Copyright © 2016 Pavel Maksimov. All rights reserved.
//

#import "PMActivityIndicator.h"

#define DEGREES_TO_RADIANS(degrees) ((3.14159265359 * degrees) / 180)

@interface PMActivityIndicator ()

@property (nonatomic) CFTimeInterval firstTimestamp;
@property (nonatomic) NSInteger iteration;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic) BOOL isCircleSpinner;

@end

@implementation PMActivityIndicator

- (CGFloat)duration
{
    if (!_duration)
        _duration = 1.0;
    return _duration;
}

- (CGFloat)radius
{
    if (!_radius)
        _radius = MIN(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height) / 15;
    return _radius;
}

- (CGFloat)lineWidth
{
    if (!_lineWidth)
        _lineWidth = 3.0;
    return _lineWidth;
}

- (NSString *)displayText
{
    if (!_message)
        _message = @"";
    return _message;
}

- (UIColor *)color
{
    if (!_color)
        _color = UIColor.blackColor;
    return _color;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.frame = UIScreen.mainScreen.bounds;
        self.backgroundColor = UIColor.clearColor;
        self.bounceEnabled = self.blurEnabled = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (![self.message isEqualToString:@""])
    {
        CGFloat fontSize = [self fontSizeWithFont:[UIFont fontWithName:@"AvenirNext-Medium" size:30]
                                constrainedToSize:CGSizeMake(self.radius / sqrt(2.0) * 2, self.radius / sqrt(2.0) * 2)
                                  minimumFontSize:11];
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(self.center.x - self.radius / sqrt(2.0),
                                                               self.center.y - self.radius / sqrt(2.0),
                                                               self.radius / sqrt(2.0) * 2,
                                                               self.radius / sqrt(2.0) * 2)];
        self.label.font = [UIFont fontWithName:@"AvenirNext-Medium" size:fontSize];
        self.label.textColor = self.color;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.text = self.message;
        self.label.numberOfLines = 1;
        self.label.minimumScaleFactor = 0.3;
        self.label.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.label];
    }
    
    if (self.blurEnabled)
    {
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        blurView.frame = self.bounds;
        blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:blurView];
    }
    
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.path = [[self getPath] CGPath];
    self.shapeLayer.lineWidth = self.lineWidth;
    self.shapeLayer.fillColor = [UIColor.clearColor CGColor];
    self.shapeLayer.strokeColor = [self.color CGColor];
    self.shapeLayer.strokeStart = 0;
    self.shapeLayer.strokeEnd = 0;
    self.shapeLayer.frame = CGRectMake(self.center.x - self.radius, self.center.y - self.radius, 2 * self.radius, 2 * self.radius);
    [self.layer addSublayer:self.shapeLayer];
    
    [self startDisplayLink];
}

- (UIBezierPath *)getPath
{
    return [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.radius * 2, self.radius * 2) cornerRadius:self.radius];
}

- (void)startDisplayLink
{
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)handleDisplayLink:(CADisplayLink *)displayLink
{
    if (!self.firstTimestamp)
    {
        self.firstTimestamp = displayLink.timestamp;
        self.iteration = -1;
        [self rotateSpinner];
    }
    
    if ((int)floor((displayLink.timestamp - self.firstTimestamp) / self.duration) != self.iteration)
    {
        self.iteration = (int)floor((displayLink.timestamp - self.firstTimestamp) / self.duration);
        
        if (self.isCircleSpinner)
        {
            if (self.iteration % 2 == 0)
                [self setStrokeStartPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1) duration:self.duration * 0.8];
            else
                [self setStrokeStartPoint:CGPointMake(0, 1) endPoint:CGPointMake(0, 1) duration:self.duration];
        }
        else
        {
            if (self.iteration % 4 == 0)
                [self setStrokeStartPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0.5) duration:self.duration * 0.8];
            else if (self.iteration % 4 == 1)
                [self setStrokeStartPoint:CGPointMake(0, 0.5) endPoint:CGPointMake(0, 0.5) duration:self.duration];
            else if (self.iteration % 4 == 2)
                [self setStrokeStartPoint:CGPointMake(0.5, 0.5) endPoint:CGPointMake(1, 1.0) duration:self.duration * 0.8];
            else if (self.iteration % 4 == 3)
                [self setStrokeStartPoint:CGPointMake(0.5, 1.0) endPoint:CGPointMake(0, 1.0) duration:self.duration];
        }
        
        if (self.bounceEnabled && self.iteration % 2 == 0)
            [self bounceLabel];
    }
}

- (void)setStrokeStartPoint:(CGPoint)start endPoint:(CGPoint)end duration:(CGFloat)duration
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.shapeLayer.strokeStart = start.x;
    self.shapeLayer.strokeEnd = start.y;
    [CATransaction commit];
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    if (end.x == 0)
        self.shapeLayer.strokeStart = end.y;
    else if (end.x == 1)
        self.shapeLayer.strokeEnd = end.y;
    [CATransaction commit];
}

- (void)rotateSpinner
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @0;
    animation.toValue = [NSNumber numberWithFloat:M_PI * 2];
    animation.duration = self.duration * 1.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.repeatCount = INFINITY;
    [self.shapeLayer addAnimation:animation forKey:@"transform.rotation.z"];
}

- (void)bounceLabel
{
    [UIView animateWithDuration:self.duration * 0.2
                          delay:self.duration * 0.5
         usingSpringWithDamping:1.0
          initialSpringVelocity:10.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.label.transform = CGAffineTransformMakeScale(1.2, 1.2);
                     }
                     completion:nil];
    
    [UIView animateWithDuration:self.duration * 0.8
                          delay:self.duration * 0.7
         usingSpringWithDamping:0.2
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.label.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     }
                     completion:nil];
}

- (CGFloat)fontSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size minimumFontSize:(CGFloat)minimumFontSize
{
    CGFloat fontSize = [font pointSize];
    CGFloat height = [self.message boundingRectWithSize:CGSizeMake(size.width, FLT_MAX)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{ NSFontAttributeName: font }
                                                context:nil].size.height;
    UIFont *newFont = font;
    
    while (height > size.height && height != 0 && fontSize > minimumFontSize)
    {
        fontSize--;
        newFont = [UIFont fontWithName:font.fontName size:fontSize];
        height = [self.message boundingRectWithSize:CGSizeMake(size.width, FLT_MAX)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{ NSFontAttributeName: newFont }
                                            context:nil].size.height;
    };
    
    return fontSize;
}

- (void)circleSpinner
{
    self.isCircleSpinner = YES;
}

- (void)halfCircleSpinner
{
    self.isCircleSpinner = NO;
}

- (void)show
{
    [UIApplication.sharedApplication.delegate.window.rootViewController.view addSubview:self];
}

- (void)hide
{
    if (self.superview)
    {
        [self removeFromSuperview];
        [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

@end

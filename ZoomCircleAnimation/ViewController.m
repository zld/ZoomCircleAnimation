//
//  ViewController.m
//  ZoomCircleAnimation
//
//  Created by 朱里达 on 16/8/3.
//  Copyright © 2016年 zld. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *startButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.startButton];
}

#pragma mark - Animation
- (void)growTapCircle
{
    //NSLog(@"expanding a tap circle");
    UIColor *tapCircleColor = [UIColor colorWithRed:0 green:216.0/255.f blue:201.f/255.f alpha:1];
    
    // Calculate the tap circle's ending diameter:
    CGFloat tapCircleFinalDiameter = [UIScreen mainScreen].bounds.size.height * 2.2;
    
    // Create a UIView which we can modify for its frame value later (specifically, the ability to use .center):
    UIView *tapCircleLayerSizerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tapCircleFinalDiameter, tapCircleFinalDiameter)];
    tapCircleLayerSizerView.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height - (49 - 10.5));
    
    // Calculate starting path:
    CGFloat tapCircleDiameterStartValue = 5.f;
    UIView *startingRectSizerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tapCircleDiameterStartValue, tapCircleDiameterStartValue)];
    startingRectSizerView.center = tapCircleLayerSizerView.center;
    
    // Create starting circle path:
    UIBezierPath *startingCirclePath = [UIBezierPath bezierPathWithRoundedRect:startingRectSizerView.frame cornerRadius:tapCircleDiameterStartValue / 2.f];
    
    // Calculate ending path:
    UIView *endingRectSizerView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height * 0.5, tapCircleFinalDiameter, tapCircleFinalDiameter)];
//    endingRectSizerView.center = tapCircleLayerSizerView.center;
    endingRectSizerView.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.5);
    
    // Create ending circle path:
    UIBezierPath *endingCirclePath = [UIBezierPath bezierPathWithRoundedRect:endingRectSizerView.frame cornerRadius:tapCircleFinalDiameter / 2.f];
    
    // Create tap circle:
    CAShapeLayer *tapCircle = [CAShapeLayer layer];
    tapCircle.fillColor = tapCircleColor.CGColor;
    tapCircle.strokeColor = [UIColor clearColor].CGColor;
    tapCircle.borderColor = [UIColor clearColor].CGColor;
    tapCircle.borderWidth = 0;
    tapCircle.path = startingCirclePath.CGPath;
    
    // Create a mask if we are not going to ripple over bounds:
    CAShapeLayer *mask = [CAShapeLayer layer];
    CGRect fadeAndClippingMaskRect = [UIScreen mainScreen].bounds;
    mask.path = [UIBezierPath bezierPathWithRoundedRect:fadeAndClippingMaskRect cornerRadius:[UIApplication sharedApplication].keyWindow.layer.cornerRadius].CGPath;
    mask.fillColor = [UIColor blackColor].CGColor;
    mask.strokeColor = [UIColor clearColor].CGColor;
    mask.borderColor = [UIColor clearColor].CGColor;
    mask.borderWidth = 0;
    
    // Set tap circle layer's mask to the mask:
    tapCircle.mask = mask;
    
    CGFloat touchDownAnimationDuration = .3f;
    
    // Grow tap-circle animation (performed on mask layer):
    CABasicAnimation *tapCircleGrowthAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    tapCircleGrowthAnimation.delegate = self;
    tapCircleGrowthAnimation.duration = touchDownAnimationDuration;
    tapCircleGrowthAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    tapCircleGrowthAnimation.fromValue = (__bridge id)startingCirclePath.CGPath;
    tapCircleGrowthAnimation.toValue = (__bridge id)endingCirclePath.CGPath;
    tapCircleGrowthAnimation.fillMode = kCAFillModeForwards;
    tapCircleGrowthAnimation.removedOnCompletion = NO;
    
    CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOut.duration = touchDownAnimationDuration;
    fadeOut.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    fadeOut.fromValue = [NSNumber numberWithFloat:1.f];
    fadeOut.toValue = [NSNumber numberWithFloat:0.f];
    fadeOut.fillMode = kCAFillModeForwards;
    fadeOut.removedOnCompletion = NO;
    fadeOut.beginTime = CACurrentMediaTime() + touchDownAnimationDuration;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions([UIApplication sharedApplication].keyWindow.bounds.size, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext([UIApplication sharedApplication].keyWindow.bounds.size);
    }
    
    [[UIApplication sharedApplication].keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CALayer *imageLayer = [[CALayer alloc] init];
    imageLayer.frame = [UIScreen mainScreen].bounds;
    imageLayer.contents = (__bridge id _Nullable)(image.CGImage);
    
    [[UIApplication sharedApplication].keyWindow.layer addSublayer:imageLayer];
    [[UIApplication sharedApplication].keyWindow.layer addSublayer:tapCircle];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((touchDownAnimationDuration) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [imageLayer removeFromSuperlayer];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((touchDownAnimationDuration * 2) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tapCircle removeFromSuperlayer];
    });
    
    // Add the animations to the layers:
    [tapCircle addAnimation:tapCircleGrowthAnimation forKey:@"animatePath"];
    [tapCircle addAnimation:fadeOut forKey:@"fadeOut"];
}

- (CGFloat)calculateTapCircleFinalDiameter
{
    return [UIScreen mainScreen].bounds.size.height;
    
//    CGFloat finalDiameter = self.tapCircleDiameter;
//    if (self.tapCircleDiameter == bfPaperTableViewCell_tapCircleDiameterFull) {
//        // Calulate a diameter that will always cover the entire button:
//        //////////////////////////////////////////////////////////////////////////////
//        // Special thanks to github user @ThePantsThief for providing this code!    //
//        //////////////////////////////////////////////////////////////////////////////
//        CGFloat centerWidth   = self.frame.size.width;
//        CGFloat centerHeight  = self.frame.size.height;
//        CGFloat tapWidth      = 2 * MAX(self.tapPoint.x, centerWidth - self.tapPoint.x);
//        CGFloat tapHeight     = 2 * MAX(self.tapPoint.y, centerHeight - self.tapPoint.y);
//        CGFloat desiredWidth  = self.rippleFromTapLocation ? tapWidth : centerWidth;
//        CGFloat desiredHeight = self.rippleFromTapLocation ? tapHeight : centerHeight;
//        CGFloat diameter      = sqrt(pow(desiredWidth, 2) + pow(desiredHeight, 2));
//        finalDiameter = diameter;
//    }
//    else if (self.tapCircleDiameter < bfPaperTableViewCell_tapCircleDiameterFull) {    // default
//        finalDiameter = MAX(self.frame.size.width, self.frame.size.height);
//    }
//    return finalDiameter;
}

#pragma mark - Getter

- (UIButton *)startButton {
    if (!_startButton) {
        _startButton = [[UIButton alloc] initWithFrame:CGRectMake(0 , 0, 50, 50)];
        _startButton.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height - 25);
        _startButton.backgroundColor = [UIColor redColor];
        _startButton.layer.cornerRadius = 25;
        _startButton.layer.masksToBounds = YES;
        [_startButton addTarget:self action:@selector(growTapCircle) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}
@end

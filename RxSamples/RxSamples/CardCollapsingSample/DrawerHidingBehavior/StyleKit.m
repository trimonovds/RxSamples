//
//  StyleKit_Maps_Intro.m
//  RxSamples
//
//  Created by Dmitry Trimonov on 23/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StyleKit.h"

@implementation StyleKit

static UIImage* _imageOfIntro_guidance_camera = nil;

+ (UIImage*)imageOfIntro_guidance_camera
{
    if (_imageOfIntro_guidance_camera)
        return _imageOfIntro_guidance_camera;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(128, 128), NO, 0);
    [StyleKit drawIntro_guidance_camera];

    _imageOfIntro_guidance_camera = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return _imageOfIntro_guidance_camera;
}

+ (void)drawIntro_guidance_camera
{
    [StyleKit drawIntro_guidance_cameraWithFrame: CGRectMake(0, 0, 128, 128) resizing: StyleResizingBehaviorStretch];
}

+ (void)drawIntro_guidance_cameraWithFrame: (CGRect)targetFrame resizing: (StyleKitResizingBehavior)resizing
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Resize to Target Frame
    CGContextSaveGState(context);
    CGRect resizedFrame = StyleKitResizingBehaviorApply(resizing, CGRectMake(0, 0, 128, 128), targetFrame);
    CGContextTranslateCTM(context, resizedFrame.origin.x, resizedFrame.origin.y);
    CGContextScaleCTM(context, resizedFrame.size.width / 128, resizedFrame.size.height / 128);
    CGFloat resizedShadowScale = MIN(resizedFrame.size.width / 128, resizedFrame.size.height / 128);



    //// Shadow Declarations
    NSShadow* shadow4x12Blur20 = [NSShadow shadowWithColor: [UIColor.blackColor colorWithAlphaComponent: 0.2] offset: CGSizeMake(0, 4) blurRadius: 12];

    //// path- Drawing
    UIBezierPath* pathPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(16, 16, 96, 96)];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context,
                                CGSizeMake(shadow4x12Blur20.shadowOffset.width * resizedShadowScale, shadow4x12Blur20.shadowOffset.height * resizedShadowScale),
                                shadow4x12Blur20.shadowBlurRadius * resizedShadowScale,
                                [shadow4x12Blur20.shadowColor CGColor]);
    [UIColor.redColor setFill];
    [pathPath fill];
    CGContextRestoreGState(context);



    //// Path 2 Drawing
    UIBezierPath* path2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(24, 24, 80, 80)];
    [UIColor.whiteColor setFill];
    [path2Path fill];


    //// Path 3 Drawing
    UIBezierPath* path3Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(60, 56, 16, 16)];
    [[UIColor.grayColor colorWithAlphaComponent:0.1] setFill];
    [path3Path fill];

    CGContextRestoreGState(context);

}

@end

@implementation NSShadow (StyleKit_Maps_IntroAdditions)

- (instancetype)initWithColor: (UIColor*)color offset: (CGSize)offset blurRadius: (CGFloat)blurRadius
{
    self = [self init];
    if (self != nil)
    {
        self.shadowColor = color;
        self.shadowOffset = offset;
        self.shadowBlurRadius = blurRadius;
    }
    return self;
}

+ (instancetype)shadowWithColor: (UIColor*)color offset: (CGSize)offset blurRadius: (CGFloat)blurRadius
{
    return [[self alloc] initWithColor: color offset: offset blurRadius: blurRadius];
}

- (void)set
{
    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), self.shadowOffset, self.shadowBlurRadius, [self.shadowColor CGColor]);
}

@end

CGRect StyleKitResizingBehaviorApply(StyleKitResizingBehavior behavior, CGRect rect, CGRect target)
{
    if (CGRectEqualToRect(rect, target) || CGRectEqualToRect(target, CGRectZero))
        return rect;

    CGSize scales = CGSizeZero;
    scales.width = ABS(target.size.width / rect.size.width);
    scales.height = ABS(target.size.height / rect.size.height);

    switch (behavior)
    {
        case StyleKitResizingBehaviorAspectFit:
        {
            scales.width = MIN(scales.width, scales.height);
            scales.height = scales.width;
            break;
        }
        case StyleKitResizingBehaviorAspectFill:
        {
            scales.width = MAX(scales.width, scales.height);
            scales.height = scales.width;
            break;
        }
        case StyleResizingBehaviorStretch:
            break;
        case StyleResizingBehaviorCenter:
        {
            scales.width = 1;
            scales.height = 1;
            break;
        }
    }

    CGRect result = CGRectStandardize(rect);
    result.size.width *= scales.width;
    result.size.height *= scales.height;
    result.origin.x = target.origin.x + (target.size.width - result.size.width) / 2;
    result.origin.y = target.origin.y + (target.size.height - result.size.height) / 2;
    return result;
}

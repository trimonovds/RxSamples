//
//  Images.h
//  RxSamples
//
//  Created by Dmitry Trimonov on 23/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSShadow (StyleKit_Maps_IntroAdditions)

+ (instancetype)shadowWithColor: (UIColor*)color offset: (CGSize)offset blurRadius: (CGFloat)blurRadius;

- (void)set;

@end

typedef NS_ENUM(NSInteger, StyleKitResizingBehavior)
{
    StyleKitResizingBehaviorAspectFit, //!< The content is proportionally resized to fit into the target rectangle.
    StyleKitResizingBehaviorAspectFill, //!< The content is proportionally resized to completely fill the target rectangle.
    StyleResizingBehaviorStretch, //!< The content is stretched to match the entire target rectangle.
    StyleResizingBehaviorCenter, //!< The content is centered in the target rectangle, but it is NOT resized.

};

extern CGRect StyleKitResizingBehaviorApply(StyleKitResizingBehavior behavior, CGRect rect, CGRect target);

@interface StyleKit : NSObject

+ (UIImage*)imageOfIntro_guidance_camera;
+ (void)drawIntro_guidance_camera;
+ (void)drawIntro_guidance_cameraWithFrame: (CGRect)targetFrame resizing: (StyleKitResizingBehavior)resizing;
@end

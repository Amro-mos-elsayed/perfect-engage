//
//  CustomSlider.m
//
//
//  Created by PremMac on 31/07/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

#import "CustomSlider.h"

@implementation CustomSlider

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    self.backgroundColor = [UIColor blueColor];
}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -5, -10);
    return CGRectContainsPoint(bounds, point);
}


//-(CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
//{
//    NSLog(@"test called");
//    
//    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], -25 , -25);
//}


@end

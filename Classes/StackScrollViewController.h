//
//  StackScrollViewController.h
//  StackScrollView
//
//  Created by Reefaq Mohammed Mac Pro on 5/10/11.
//  Copyright 2011 raw engineering. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StackScrollViewController :  UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
	
	UIView* viewAtLeft;
	UIView* viewAtRight;
	UIView* viewAtLeft2;
	UIView* viewAtRight2;	
	UIView* viewAtRightAtTouchBegan;
	UIView* viewAtLeftAtTouchBegan;
	
	NSString* dragDirection;
	
	CGFloat viewXPosition;		
	CGFloat displacementPosition;
	CGFloat lastTouchPoint;
	CGFloat slideStartPosition;
	
	CGPoint positionOfViewAtRightAtTouchBegan;
	CGPoint positionOfViewAtLeftAtTouchBegan;
	

}

- (void) addViewInSlider:(UIViewController*)controller invokeByController:(UIViewController*)invokeByController isStackStartView:(BOOL)isStackStartView;
- (void)bounceBack:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context;

@property (nonatomic, strong) UIView* slideViews;
@property (nonatomic, strong) UIView* borderViews;
@property (nonatomic, assign) CGFloat slideStartPosition;
@property (nonatomic, strong) NSMutableArray* viewControllersStack;



@end

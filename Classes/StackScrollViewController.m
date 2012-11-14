/*
 This module is licenced under the BSD license.
 
 Copyright (C) 2011 by raw engineering <nikhil.jain (at) raweng (dot) com, reefaq.mohammed (at) raweng (dot) com>.
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  StackScrollViewController.m
//  SlidingView
//
//  Created by Reefaq on 2/24/11.
//  Copyright 2011 raw engineering . All rights reserved.
//

#import "StackScrollViewController.h"
#import "UIViewWithShadow.h"

const NSInteger SLIDE_VIEWS_MINUS_X_POSITION = -130;
const NSInteger SLIDE_VIEWS_START_X_POS = 0;

@interface StackScrollViewController ()

@property (nonatomic, strong) NSString * dragDirection;
@property (nonatomic) CGFloat viewXPosition;
@property (nonatomic) CGFloat displacementPosition;
@property (nonatomic) CGFloat lastTouchPoint; // TODO: refactor to make clear that this stores the X coordinate of last touch
@property (nonatomic, weak) UIView * viewAtLeft;
@property (nonatomic, weak) UIView * viewAtLeft2;
@property (nonatomic, weak) UIView * viewAtRight;
@property (nonatomic, weak) UIView * viewAtRight2;
@property (nonatomic, weak) UIView * viewAtRightAtTouchBegan;
@property (nonatomic, weak) UIView * viewAtLeftAtTouchBegan;
@property (nonatomic) CGPoint positionOfViewAtRightAtTouchBegan;
@property (nonatomic) CGPoint positionOfViewAtLeftAtTouchBegan;

@property (nonatomic, strong) UIView* slideViews;
@property (nonatomic, strong) UIView* borderViews;
@property (nonatomic, assign) CGFloat slideStartPosition;

@end

@implementation StackScrollViewController

//@synthesize slideViews, borderViews, viewControllersStack, slideStartPosition;

-(id)init {
	
	if(self= [super init]) {
		
		self.borderViews = [[UIView alloc] initWithFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION - 2, -2, 2, self.view.frame.size.height)];
		[_borderViews setBackgroundColor:[UIColor clearColor]];
		UIView* verticalLineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, _borderViews.frame.size.height)];
		[verticalLineView1 setBackgroundColor:[UIColor whiteColor]];
		[verticalLineView1 setTag:1];
		[verticalLineView1 setHidden:TRUE];
		[_borderViews addSubview:verticalLineView1];
		
		UIView* verticalLineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, _borderViews.frame.size.height)];
		[verticalLineView2 setBackgroundColor:[UIColor grayColor]];
		[verticalLineView2 setTag:2];
		[verticalLineView2 setHidden:TRUE];		
		[_borderViews addSubview:verticalLineView2];
		
		[self.view addSubview:_borderViews];
		
		self.slideViews = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
		[_slideViews setBackgroundColor:[UIColor clearColor]];
		[self.view setBackgroundColor:[UIColor clearColor]];
		[self.view setFrame:_slideViews.frame];
		self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		self.viewXPosition = 0.f;
		self.lastTouchPoint = -1.f;
		
		self.dragDirection = @"";
		

		
		UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
		[panRecognizer setMaximumNumberOfTouches:1];
		[panRecognizer setDelaysTouchesBegan:TRUE];
		[panRecognizer setDelaysTouchesEnded:TRUE];
		[panRecognizer setCancelsTouchesInView:TRUE];
		[self.view addGestureRecognizer:panRecognizer];
		
		[self.view addSubview:_slideViews];
		
	}
	
	return self;
}

-(void)arrangeVerticalBar {
	
	if ([[self.slideViews subviews] count] > 2) {
		[[_borderViews viewWithTag:2] setHidden:TRUE];
		[[_borderViews viewWithTag:1] setHidden:TRUE];
		NSInteger stackCount = 0;
		if (_viewAtLeft != nil ) {
			stackCount = [[_slideViews subviews] indexOfObject:_viewAtLeft];
		}
		
		if (_viewAtLeft != nil && _viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION) {
			stackCount += 1;
		}
		
		if (stackCount == 2) {
			[[_borderViews viewWithTag:2] setHidden:FALSE];
		}
		if (stackCount >= 3) {
			[[_borderViews viewWithTag:2] setHidden:FALSE];
			[[_borderViews viewWithTag:1] setHidden:FALSE];
		}
		
		
	}
}


- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
	
	CGPoint translatedPoint = [recognizer translationInView:self.view];
	
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		_displacementPosition = 0.f;
		_positionOfViewAtRightAtTouchBegan = _viewAtRight.frame.origin;
		_positionOfViewAtLeftAtTouchBegan = _viewAtLeft.frame.origin;
		_viewAtRightAtTouchBegan = _viewAtRight;
		_viewAtLeftAtTouchBegan = _viewAtLeft;
		[_viewAtLeft.layer removeAllAnimations];
		[_viewAtRight.layer removeAllAnimations];
		[_viewAtRight2.layer removeAllAnimations];
		[_viewAtLeft2.layer removeAllAnimations];
		if (_viewAtLeft2 != nil) {
			NSInteger _viewAtLeft2Position = [[_slideViews subviews] indexOfObject:_viewAtLeft2];
			if  (_viewAtLeft2Position > 0) {
				[((UIView*)[_slideViews subviews] [_viewAtLeft2Position -1]) setHidden:NO];
			}
		}
		
		[self arrangeVerticalBar];
	}
	
	
	CGPoint location =  [recognizer locationInView:self.view];
	
	if (_lastTouchPoint != -1) {
		
		if (location.x < _lastTouchPoint) {			
			
			if ([_dragDirection isEqualToString:@"RIGHT"]) {
			_positionOfViewAtRightAtTouchBegan = _viewAtRight.frame.origin;
				_positionOfViewAtLeftAtTouchBegan = _viewAtLeft.frame.origin;
				_displacementPosition = translatedPoint.x * -1;
			}				
			
			_dragDirection = @"LEFT";
			
			if (_viewAtRight != nil) {
				
				if (_viewAtLeft.frame.origin.x <= SLIDE_VIEWS_MINUS_X_POSITION) {
					if ([[_slideViews subviews] indexOfObject:_viewAtRight] < ([[_slideViews subviews] count]-1)) {
						_viewAtLeft2 = _viewAtLeft;
						_viewAtLeft = _viewAtRight;
						[_viewAtRight2 setHidden:FALSE];
						_viewAtRight = _viewAtRight2;
						if ([[_slideViews subviews] indexOfObject:_viewAtRight] < ([[_slideViews subviews] count]-1)) {
							_viewAtRight2 = [_slideViews subviews][[[_slideViews subviews] indexOfObject:_viewAtRight] + 1];
						}else {
							_viewAtRight2 = nil;
						}							
						_positionOfViewAtRightAtTouchBegan = _viewAtRight.frame.origin;
						_positionOfViewAtLeftAtTouchBegan = _viewAtLeft.frame.origin;
						_displacementPosition = translatedPoint.x * -1;
						if ([[_slideViews subviews] indexOfObject:_viewAtLeft2] > 1) {
							[[_slideViews subviews][[[_slideViews subviews] indexOfObject:_viewAtLeft2] - 2] setHidden:YES];
						}
						
					}
					
				}
				
				if (_viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION && _viewAtRight.frame.origin.x + _viewAtRight.frame.size.width > self.view.frame.size.width) {
					if ((_positionOfViewAtRightAtTouchBegan.x + translatedPoint.x + _displacementPosition + _viewAtRight.frame.size.width) <= self.view.frame.size.width) {
						[_viewAtRight setFrame:CGRectMake(self.view.frame.size.width - _viewAtRight.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
					}else {
						[_viewAtRight setFrame:CGRectMake(_positionOfViewAtRightAtTouchBegan.x + translatedPoint.x + _displacementPosition, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
					}
					
				}
				else if (([[_slideViews subviews] indexOfObject:_viewAtRight] == [[_slideViews subviews] count]-1) && _viewAtRight.frame.origin.x <= (self.view.frame.size.width - _viewAtRight.frame.size.width)) {
					if ((_positionOfViewAtRightAtTouchBegan.x + translatedPoint.x + _displacementPosition) <= SLIDE_VIEWS_MINUS_X_POSITION) {
						[_viewAtRight setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
					}else {
						[_viewAtRight setFrame:CGRectMake(_positionOfViewAtRightAtTouchBegan.x + translatedPoint.x + _displacementPosition, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
					}
				}
				else{						
					if (_positionOfViewAtLeftAtTouchBegan.x + translatedPoint.x + _displacementPosition <= SLIDE_VIEWS_MINUS_X_POSITION) {
						[_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
					}else {
						[_viewAtLeft setFrame:CGRectMake(_positionOfViewAtLeftAtTouchBegan.x + translatedPoint.x + _displacementPosition , _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
					}						
					[_viewAtRight setFrame:CGRectMake(_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
					
					if (_viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION) {
						_positionOfViewAtRightAtTouchBegan = _viewAtRight.frame.origin;
						_positionOfViewAtLeftAtTouchBegan = _viewAtLeft.frame.origin;
						_displacementPosition = translatedPoint.x * -1;
					}
					
				}
				
			}else {
				[_viewAtLeft setFrame:CGRectMake(_positionOfViewAtLeftAtTouchBegan.x + translatedPoint.x + _displacementPosition , _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
			}
			
			[self arrangeVerticalBar];
			
		}else if (location.x > _lastTouchPoint) {
			
			if ([_dragDirection isEqualToString:@"LEFT"]) {
			_positionOfViewAtRightAtTouchBegan = _viewAtRight.frame.origin;
				_positionOfViewAtLeftAtTouchBegan = _viewAtLeft.frame.origin;
				_displacementPosition = translatedPoint.x;
			}	
			
			_dragDirection = @"RIGHT";
			
			if (_viewAtLeft != nil) {
				
				if (_viewAtRight.frame.origin.x >= self.view.frame.size.width) {
					
					if ([[_slideViews subviews] indexOfObject:_viewAtLeft] > 0) {
						[_viewAtRight2 setHidden:TRUE];
						_viewAtRight2 = _viewAtRight;
						_viewAtRight = _viewAtLeft;
						_viewAtLeft = _viewAtLeft2;
						if ([[_slideViews subviews] indexOfObject:_viewAtLeft] > 0) {
							_viewAtLeft2 = [_slideViews subviews][[[_slideViews subviews] indexOfObject:_viewAtLeft] - 1];
							[_viewAtLeft2 setHidden:FALSE];
						}
						else{
							_viewAtLeft2 = nil;
						}
						_positionOfViewAtRightAtTouchBegan = _viewAtRight.frame.origin;
						_positionOfViewAtLeftAtTouchBegan = _viewAtLeft.frame.origin;
						_displacementPosition = translatedPoint.x;
						
						[self arrangeVerticalBar];
					}
				}
				
				if((_viewAtRight.frame.origin.x < (_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width)) && _viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION){
					if ((_positionOfViewAtRightAtTouchBegan.x + translatedPoint.x - _displacementPosition) >= (_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width)) {
						[_viewAtRight setFrame:CGRectMake(_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
					}else {
						[_viewAtRight setFrame:CGRectMake(_positionOfViewAtRightAtTouchBegan.x + translatedPoint.x - _displacementPosition, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
					}
					
				}
				else if ([[_slideViews subviews] indexOfObject:_viewAtLeft] == 0) {
					if (_viewAtRight == nil) {
						[_viewAtLeft setFrame:CGRectMake(_positionOfViewAtLeftAtTouchBegan.x + translatedPoint.x - _displacementPosition, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
					}
					else{
						[_viewAtRight setFrame:CGRectMake(_positionOfViewAtRightAtTouchBegan.x + translatedPoint.x - _displacementPosition, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
						if (_viewAtRight.frame.origin.x - _viewAtLeft.frame.size.width < SLIDE_VIEWS_MINUS_X_POSITION) {
							[_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
						}else{
							 [_viewAtLeft setFrame:CGRectMake (_viewAtRight.frame.origin.x - _viewAtLeft.frame.size.width, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
						}
					}
				}					
				else{
					if ( (_positionOfViewAtRightAtTouchBegan.x + translatedPoint.x - _displacementPosition) >= self.view.frame.size.width) {
						 [_viewAtRight setFrame:CGRectMake(self.view.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
					}else {
						 [_viewAtRight setFrame:CGRectMake (_positionOfViewAtRightAtTouchBegan.x + translatedPoint.x - _displacementPosition, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
					}
					if  (_viewAtRight.frame.origin.x - _viewAtLeft.frame.size.width < SLIDE_VIEWS_MINUS_X_POSITION) {
						 [_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
					}
					else{
						 [_viewAtLeft setFrame:CGRectMake (_viewAtRight.frame.origin.x - _viewAtLeft.frame.size.width, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
					}
					if  (_viewAtRight.frame.origin.x >= self.view.frame.size.width) {
					 	_positionOfViewAtRightAtTouchBegan = _viewAtRight.frame.origin;
					 	_positionOfViewAtLeftAtTouchBegan = _viewAtLeft.frame.origin;
                        _displacementPosition = translatedPoint.x;
					}
					
					[self arrangeVerticalBar];
				}
				
			}
			
			[self arrangeVerticalBar];
		}
	}
	
	_lastTouchPoint = location.x;
	
	// STATE END	
	if (recognizer.state == UIGestureRecognizerStateEnded) {
		
		if ([_dragDirection isEqualToString:@"LEFT"]) {
			if  (_viewAtRight != nil) {
				if ([[_slideViews subviews] indexOfObject:_viewAtLeft] == 0 && ! (_viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION || _viewAtLeft.frame.origin.x == SLIDE_VIEWS_START_X_POS)) {
					[UIView beginAnimations:nil context:NULL];
					[UIView setAnimationDuration:0.2];
					[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
					[UIView setAnimationBeginsFromCurrentState:YES];
					if  (_viewAtLeft.frame.origin.x < SLIDE_VIEWS_START_X_POS && _viewAtRight != nil) {
						 [_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
						 [_viewAtRight setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION + _viewAtLeft.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width,_viewAtRight.frame.size.height)];
					}
					else{
						
						//Drop Card View Animation
						if ((((UIView*)[_slideViews subviews][0]).frame.origin.x+200) >= (self.view.frame.origin.x + ((UIView*)[_slideViews subviews][0]).frame.size.width)) {
							
							NSInteger viewControllerCount = [self.childViewControllers count];
							
							if (viewControllerCount > 1) {
								for (int i = 1; i < viewControllerCount; i++) {
			_viewXPosition = self.view.frame.size.width - [_slideViews viewWithTag:i].frame.size.width;
									[[_slideViews viewWithTag:i] removeFromSuperview];
									[[self.childViewControllers lastObject] removeFromParentViewController];
								}
								
								[[_borderViews viewWithTag:3] setHidden:TRUE];
								[[_borderViews viewWithTag:2] setHidden:TRUE];
								[[_borderViews viewWithTag:1] setHidden:TRUE];
								
							}
							
							// Removes the selection of row for the first slide view
							for (UIView* tableView in [[_slideViews subviews][0] subviews]) {
								if([tableView isKindOfClass:[UITableView class]]){
									NSIndexPath* selectedRow =  [(UITableView*)tableView indexPathForSelectedRow];
									NSArray *indexPaths = @[selectedRow];
									[(UITableView*)tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:NO];
								}
							}
							_viewAtLeft2 = nil;
			_viewAtRight = nil;
							_viewAtRight2 = nil;
						}
						
						 [_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_START_X_POS, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
						if  (_viewAtRight != nil) {
							 [_viewAtRight setFrame:CGRectMake(SLIDE_VIEWS_START_X_POS + _viewAtLeft.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width,_viewAtRight.frame.size.height)];
						}
						
					}
					[UIView commitAnimations];
				}
				else if  (_viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION && _viewAtRight.frame.origin.x + _viewAtRight.frame.size.width > self.view.frame.size.width) {
					[UIView beginAnimations:nil context:NULL];
					[UIView setAnimationDuration:0.2];
					[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
					[UIView setAnimationBeginsFromCurrentState:YES];
					 [_viewAtRight setFrame:CGRectMake(self.view.frame.size.width - _viewAtRight.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width,_viewAtRight.frame.size.height)];
					[UIView commitAnimations];						
				}	
				else if  (_viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION && _viewAtRight.frame.origin.x + _viewAtRight.frame.size.width < self.view.frame.size.width) {
					[UIView beginAnimations:@"RIGHT-WITH-RIGHT" context:NULL];
					[UIView setAnimationDuration:0.2];
					[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
					[UIView setAnimationBeginsFromCurrentState:YES];
					 [_viewAtRight setFrame:CGRectMake(self.view.frame.size.width - _viewAtRight.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width,_viewAtRight.frame.size.height)];
					[UIView setAnimationDelegate:self];
					[UIView setAnimationDidStopSelector:@selector(bounceBack:finished:context:)];
					[UIView commitAnimations];
				}
				else if  (_viewAtLeft.frame.origin.x > SLIDE_VIEWS_MINUS_X_POSITION) {
					[UIView setAnimationDuration:0.2];
					[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
					[UIView setAnimationBeginsFromCurrentState:YES];
					if ( (_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width > self.view.frame.size.width) && _viewAtLeft.frame.origin.x < (self.view.frame.size.width -  (_viewAtLeft.frame.size.width)/2)) {
						[UIView beginAnimations:@"LEFT-WITH-LEFT" context:nil];
						 [_viewAtLeft setFrame:CGRectMake(self.view.frame.size.width - _viewAtLeft.frame.size.width, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
						
						//Show bounce effect
						 [_viewAtRight setFrame:CGRectMake(self.view.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
					}
					else {
						[UIView beginAnimations:@"LEFT-WITH-RIGHT" context:nil];	
						 [_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
						if  (_positionOfViewAtLeftAtTouchBegan.x + _viewAtLeft.frame.size.width <= self.view.frame.size.width) {
							 [_viewAtRight setFrame:CGRectMake((self.view.frame.size.width - _viewAtRight.frame.size.width), _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];						
						}
						else{
							 [_viewAtRight setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION + _viewAtLeft.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];						
						}
						
						//Show bounce effect
						 [_viewAtRight2 setFrame:CGRectMake (_viewAtRight.frame.origin.x + _viewAtRight.frame.size.width, _viewAtRight2.frame.origin.y, _viewAtRight2.frame.size.width, _viewAtRight2.frame.size.height)];
					}
					[UIView setAnimationDelegate:self];
					[UIView setAnimationDidStopSelector:@selector(bounceBack:finished:context:)];
					[UIView commitAnimations];
				}
				
			}
			else{
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.2];
				[UIView setAnimationBeginsFromCurrentState:YES];
				[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
				 [_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_START_X_POS, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
				[UIView commitAnimations];
			}
			
		}else if ([_dragDirection isEqualToString:@"RIGHT"]) {
			if  (_viewAtLeft != nil) {
				if ([[_slideViews subviews] indexOfObject:_viewAtLeft] == 0 && ! (_viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION || _viewAtLeft.frame.origin.x == SLIDE_VIEWS_START_X_POS)) {
					[UIView beginAnimations:nil context:NULL];
					[UIView setAnimationDuration:0.2];			
					[UIView setAnimationBeginsFromCurrentState:YES];
					[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
					if  (_viewAtLeft.frame.origin.x > SLIDE_VIEWS_MINUS_X_POSITION || _viewAtRight == nil) {
						
						//Drop Card View Animation
						if ((((UIView*)[_slideViews subviews][0]).frame.origin.x+200) >= (self.view.frame.origin.x + ((UIView*)[_slideViews subviews][0]).frame.size.width)) {
							NSInteger viewControllerCount = [self.childViewControllers count];
							if (viewControllerCount > 1) {
								for (int i = 1; i < viewControllerCount; i++) {
			_viewXPosition = self.view.frame.size.width - [_slideViews viewWithTag:i].frame.size.width;
									[[_slideViews viewWithTag:i] removeFromSuperview];
									[[self.childViewControllers lastObject] removeFromParentViewController];
								}
								[[_borderViews viewWithTag:3] setHidden:TRUE];
								[[_borderViews viewWithTag:2] setHidden:TRUE];
								[[_borderViews viewWithTag:1] setHidden:TRUE];
							}
							
							// Removes the selection of row for the first slide view
							for (UIView* tableView in [[_slideViews subviews][0] subviews]) {
								if([tableView isKindOfClass:[UITableView class]]){
									NSIndexPath* selectedRow =  [(UITableView*)tableView indexPathForSelectedRow];
									NSArray *indexPaths = @[selectedRow];
									[(UITableView*)tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:NO];
								}
							}
							
							_viewAtLeft2 = nil;
							_viewAtRight = nil;
							_viewAtRight2 = nil;							 
						}
						 [_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_START_X_POS, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
						if  (_viewAtRight != nil) {
							 [_viewAtRight setFrame:CGRectMake(SLIDE_VIEWS_START_X_POS + _viewAtLeft.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
						}
					}
					else{
						 [_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
						 [_viewAtRight setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION + _viewAtLeft.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
					}
					[UIView commitAnimations];
				}
				else if  (_viewAtRight.frame.origin.x < self.view.frame.size.width) {
					if( (_viewAtRight.frame.origin.x <  (_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width)) && _viewAtRight.frame.origin.x < (self.view.frame.size.width -  (_viewAtRight.frame.size.width/2))){
						[UIView beginAnimations:@"RIGHT-WITH-RIGHT" context:NULL];
						[UIView setAnimationDuration:0.2];
						[UIView setAnimationBeginsFromCurrentState:YES];
						[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
						 [_viewAtRight setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION + _viewAtLeft.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];						
						[UIView setAnimationDelegate:self];
						[UIView setAnimationDidStopSelector:@selector(bounceBack:finished:context:)];
						[UIView commitAnimations];
					}				
					else{
						
						[UIView beginAnimations:@"RIGHT-WITH-LEFT" context:NULL];
						[UIView setAnimationDuration:0.2];
						[UIView setAnimationBeginsFromCurrentState:YES];
						[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
						if([[_slideViews subviews] indexOfObject:_viewAtLeft] > 0){ 
							if  (_positionOfViewAtRightAtTouchBegan.x  + _viewAtRight.frame.size.width <= self.view.frame.size.width) {							
								 [_viewAtLeft setFrame:CGRectMake(self.view.frame.size.width - _viewAtLeft.frame.size.width, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
							}
							else{							
								 [_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION + _viewAtLeft2.frame.size.width, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
							}
							 [_viewAtRight setFrame:CGRectMake(self.view.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];		
						}
						else{
							 [_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
							 [_viewAtRight setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION + _viewAtLeft.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
						}
						[UIView setAnimationDelegate:self];
						[UIView setAnimationDidStopSelector:@selector(bounceBack:finished:context:)];
						[UIView commitAnimations];
					}
					
				}
			}			
		}
		_lastTouchPoint = -1;
		_dragDirection = @"";
	}	
	
}

- (void)bounceBack:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {	
	
	BOOL isBouncing = FALSE;
	
	if([_dragDirection isEqualToString:@""] && [finished boolValue]){
		 [_viewAtLeft.layer removeAllAnimations];
		 [_viewAtRight.layer removeAllAnimations];
		 [_viewAtRight2.layer removeAllAnimations];
		 [_viewAtLeft2.layer removeAllAnimations];
            if ([animationID isEqualToString:@"LEFT-WITH-LEFT"] && _viewAtLeft2.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION) {
                CABasicAnimation *bounceAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
                bounceAnimation.duration = 0.2;
                bounceAnimation.fromValue = @ (_viewAtLeft.center.x);
                bounceAnimation.toValue = @ (_viewAtLeft.center.x -10);
                bounceAnimation.repeatCount = 0;
                bounceAnimation.autoreverses = YES;
                bounceAnimation.fillMode = kCAFillModeBackwards;
                bounceAnimation.removedOnCompletion = YES;
                bounceAnimation.additive = NO;
                 [_viewAtLeft.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
                
                 [_viewAtRight setHidden:FALSE];
                CABasicAnimation *bounceAnimationForRight = [CABasicAnimation animationWithKeyPath:@"position.x"];
                bounceAnimationForRight.duration = 0.2;
                bounceAnimationForRight.fromValue = @ (_viewAtRight.center.x);
                bounceAnimationForRight.toValue = @ (_viewAtRight.center.x - 20);
                bounceAnimationForRight.repeatCount = 0;
                bounceAnimationForRight.autoreverses = YES;
                bounceAnimationForRight.fillMode = kCAFillModeBackwards;
                bounceAnimationForRight.removedOnCompletion = YES;
                bounceAnimationForRight.additive = NO;
                 [_viewAtRight.layer addAnimation:bounceAnimationForRight forKey:@"bounceAnimationRight"];
            }else if ([animationID isEqualToString:@"LEFT-WITH-RIGHT"]  && _viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION) {
                CABasicAnimation *bounceAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
                bounceAnimation.duration = 0.2;
                bounceAnimation.fromValue = @ (_viewAtRight.center.x);
                bounceAnimation.toValue = @ (_viewAtRight.center.x - 10);
                bounceAnimation.repeatCount = 0;
                bounceAnimation.autoreverses = YES;
                bounceAnimation.fillMode = kCAFillModeBackwards;
                bounceAnimation.removedOnCompletion = YES;
                bounceAnimation.additive = NO;
                 [_viewAtRight.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
                
                
                 [_viewAtRight2 setHidden:FALSE];
                CABasicAnimation *bounceAnimationForRight2 = [CABasicAnimation animationWithKeyPath:@"position.x"];
                bounceAnimationForRight2.duration = 0.2;
                bounceAnimationForRight2.fromValue = @ (_viewAtRight2.center.x);
                bounceAnimationForRight2.toValue = @ (_viewAtRight2.center.x - 20);
                bounceAnimationForRight2.repeatCount = 0;
                bounceAnimationForRight2.autoreverses = YES;
                bounceAnimationForRight2.fillMode = kCAFillModeBackwards;
                bounceAnimationForRight2.removedOnCompletion = YES;
                bounceAnimationForRight2.additive = NO;
                 [_viewAtRight2.layer addAnimation:bounceAnimationForRight2 forKey:@"bounceAnimationRight2"];
            }else if ([animationID isEqualToString:@"RIGHT-WITH-RIGHT"]) {
                CABasicAnimation *bounceAnimationLeft = [CABasicAnimation animationWithKeyPath:@"position.x"];
                bounceAnimationLeft.duration = 0.2;
                bounceAnimationLeft.fromValue = @ (_viewAtLeft.center.x);
                bounceAnimationLeft.toValue = @ (_viewAtLeft.center.x + 10);
                bounceAnimationLeft.repeatCount = 0;
                bounceAnimationLeft.autoreverses = YES;
                bounceAnimationLeft.fillMode = kCAFillModeBackwards;
                bounceAnimationLeft.removedOnCompletion = YES;
                bounceAnimationLeft.additive = NO;
                 [_viewAtLeft.layer addAnimation:bounceAnimationLeft forKey:@"bounceAnimationLeft"];
                
                CABasicAnimation *bounceAnimationRight = [CABasicAnimation animationWithKeyPath:@"position.x"];
                bounceAnimationRight.duration = 0.2;
                bounceAnimationRight.fromValue = @ (_viewAtRight.center.x);
                bounceAnimationRight.toValue = @ (_viewAtRight.center.x + 10);
                bounceAnimationRight.repeatCount = 0;
                bounceAnimationRight.autoreverses = YES;
                bounceAnimationRight.fillMode = kCAFillModeBackwards;
                bounceAnimationRight.removedOnCompletion = YES;
                bounceAnimationRight.additive = NO;
                 [_viewAtRight.layer addAnimation:bounceAnimationRight forKey:@"bounceAnimationRight"];
                
            }else if ([animationID isEqualToString:@"RIGHT-WITH-LEFT"]) {
                CABasicAnimation *bounceAnimationLeft = [CABasicAnimation animationWithKeyPath:@"position.x"];
                bounceAnimationLeft.duration = 0.2;
                bounceAnimationLeft.fromValue = @ (_viewAtLeft.center.x);
                bounceAnimationLeft.toValue = @ (_viewAtLeft.center.x + 10);
                bounceAnimationLeft.repeatCount = 0;
                bounceAnimationLeft.autoreverses = YES;
                bounceAnimationLeft.fillMode = kCAFillModeBackwards;
                bounceAnimationLeft.removedOnCompletion = YES;
                bounceAnimationLeft.additive = NO;
                 [_viewAtLeft.layer addAnimation:bounceAnimationLeft forKey:@"bounceAnimationLeft"];
                
                if  (_viewAtLeft2 != nil) {
                     [_viewAtLeft2 setHidden:FALSE];
                    NSInteger _viewAtLeft2Position = [[_slideViews subviews] indexOfObject:_viewAtLeft2];
                    if  (_viewAtLeft2Position > 0) {
                        [((UIView*)[_slideViews subviews] [_viewAtLeft2Position -1]) setHidden:FALSE];
                    }
                    CABasicAnimation* bounceAnimationLeft2 = [CABasicAnimation animationWithKeyPath:@"position.x"];
                    bounceAnimationLeft2.duration = 0.2;
                    bounceAnimationLeft2.fromValue = @ (_viewAtLeft2.center.x);
                    bounceAnimationLeft2.toValue = @ (_viewAtLeft2.center.x + 10);
                    bounceAnimationLeft2.repeatCount = 0;
                    bounceAnimationLeft2.autoreverses = YES;
                    bounceAnimationLeft2.fillMode = kCAFillModeBackwards;
                    bounceAnimationLeft2.removedOnCompletion = YES;
                    bounceAnimationLeft2.additive = NO;
                     [_viewAtLeft2.layer addAnimation:bounceAnimationLeft2 forKey:@"bounceAnimationviewAtLeft2"];
                    [self performSelector:@selector(callArrangeVerticalBar) withObject:nil afterDelay:0.4];
                    isBouncing = TRUE;
                }
                
            }
		
	}
	[self arrangeVerticalBar];	
	if ([[_slideViews subviews] indexOfObject:_viewAtLeft2] == 1 && isBouncing) {
		[[_borderViews viewWithTag:2] setHidden:TRUE];
	}
}


- (void)callArrangeVerticalBar{
	[self arrangeVerticalBar];
}

- (void)loadView {
	[super loadView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)addViewInSlider:(UIViewController*)controller invokeByController:(UIViewController*)invokeByController isStackStartView:(BOOL)isStackStartView{
		
    
    
	if (isStackStartView) {
		_slideStartPosition = SLIDE_VIEWS_START_X_POS;
		_viewXPosition = _slideStartPosition;
		
		for (UIView* subview in [_slideViews subviews]) {
			[subview removeFromSuperview];
		}
		
		[[_borderViews viewWithTag:3] setHidden:TRUE];
		[[_borderViews viewWithTag:2] setHidden:TRUE];
		[[_borderViews viewWithTag:1] setHidden:TRUE];
        for (UIViewController *vc in self.childViewControllers) {
            [vc willMoveToParentViewController:nil];
            [vc removeFromParentViewController];
        }
	}

    
	if([self.childViewControllers count] > 1){
		NSInteger indexOfViewController = [self.childViewControllers
										   indexOfObject:invokeByController]+1;
		
//		if ([invokeByController parentViewController]) {
//			indexOfViewController = [self.childViewControllers
//									 indexOfObject:[invokeByController parentViewController]]+1;
//		}
		
		NSInteger viewControllerCount = [self.childViewControllers count];
		for (int i = indexOfViewController; i < viewControllerCount; i++) {
			[[_slideViews viewWithTag:i] removeFromSuperview];
            UIViewController * vc = [self.childViewControllers objectAtIndex:indexOfViewController];
            [vc willMoveToParentViewController:nil];
            [vc removeFromParentViewController];
			_viewXPosition = self.view.frame.size.width - [controller view].frame.size.width;
		}
	}else if([self.childViewControllers count] == 0) {
		for (UIView* subview in [_slideViews subviews]) {
			[subview removeFromSuperview];
		}
        for (UIViewController *vc in self.childViewControllers) {
            [vc willMoveToParentViewController:nil];
            [vc removeFromParentViewController];
        }
		[[_borderViews viewWithTag:3] setHidden:TRUE];
		[[_borderViews viewWithTag:2] setHidden:TRUE];
		[[_borderViews viewWithTag:1] setHidden:TRUE];
	}

	if ([_slideViews.subviews count] != 0) {
		UIViewWithShadow* verticalLineView = [[UIViewWithShadow alloc] initWithFrame:CGRectMake(-40, 0, 40 , self.view.frame.size.height)];
		[verticalLineView setBackgroundColor:[UIColor clearColor]];
		[verticalLineView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
		[verticalLineView setClipsToBounds:NO];
		[controller.view addSubview:verticalLineView];
	}

	[self addChildViewController:controller];
    [controller didMoveToParentViewController:self];

	if (invokeByController !=nil) {
		_viewXPosition = invokeByController.view.frame.origin.x + invokeByController.view.frame.size.width;
	}
	if ([[_slideViews subviews] count] == 0) {
		_slideStartPosition = SLIDE_VIEWS_START_X_POS;
		_viewXPosition = _slideStartPosition;
	}
	[[controller view] setFrame:CGRectMake(_viewXPosition, 0, [controller view].frame.size.width, self.view.frame.size.height)];
	
	[controller.view setTag:([self.childViewControllers count]-1)];
//	[controller viewWillAppear:FALSE];
//	[controller viewDidAppear:FALSE];
	[_slideViews addSubview:[controller view]];
	
	
	if ([[_slideViews subviews] count] > 0) {
		
		if ([[_slideViews subviews] count]==1) {
			_viewAtLeft = [_slideViews subviews][[[_slideViews subviews] count]-1];
			_viewAtLeft2 = nil;
			_viewAtRight = nil;
			_viewAtRight2 = nil;
			
		}else if ([[_slideViews subviews] count]==2){
			_viewAtRight = [_slideViews subviews][[[_slideViews subviews] count]-1];
			_viewAtLeft = [_slideViews subviews][[[_slideViews subviews] count]-2];
			_viewAtLeft2 = nil;
			_viewAtRight2 = nil;
			
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:_viewAtLeft cache:YES];	
			[UIView setAnimationBeginsFromCurrentState:NO];	
			 [_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
			 [_viewAtRight setFrame:CGRectMake(self.view.frame.size.width - _viewAtRight.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
			[UIView commitAnimations];
			_slideStartPosition = SLIDE_VIEWS_MINUS_X_POSITION;
			
		}else {
			
			
				_viewAtRight = [_slideViews subviews][[[_slideViews subviews] count]-1];
				_viewAtLeft = [_slideViews subviews][[[_slideViews subviews] count]-2];
				_viewAtLeft2 = [_slideViews subviews][[[_slideViews subviews] count]-3];
				 [_viewAtLeft2 setHidden:FALSE];
				_viewAtRight2 = nil;
				
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:_viewAtLeft cache:YES];	
				[UIView setAnimationBeginsFromCurrentState:NO];	
				
                if  (_viewAtLeft2.frame.origin.x != SLIDE_VIEWS_MINUS_X_POSITION) {
                     [_viewAtLeft2 setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtLeft2.frame.origin.y, _viewAtLeft2.frame.size.width, _viewAtLeft2.frame.size.height)];
                }
                 [_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
				 [_viewAtRight setFrame:CGRectMake(self.view.frame.size.width - _viewAtRight.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(bounceBack:finished:context:)];
				[UIView commitAnimations];				
				_slideStartPosition = SLIDE_VIEWS_MINUS_X_POSITION;
				if([[_slideViews subviews] count] > 3){
					[[_slideViews subviews][[[_slideViews subviews] count]-4] setHidden:TRUE];		
				}
			
			
		}
	}
}

#pragma mark -
#pragma mark Rotation support


// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	BOOL isViewOutOfScreen = FALSE; 
	for (UIViewController* subController in self.childViewControllers) {
		if  (_viewAtRight != nil &&  [_viewAtRight isEqual:subController.view]) {
			if  (_viewAtRight.frame.origin.x <=  (_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width)) {
				[subController.view setFrame:CGRectMake(self.view.frame.size.width - subController.view.frame.size.width, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
			}else{
				[subController.view setFrame:CGRectMake (_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
			}
			isViewOutOfScreen = TRUE;
		}
		else if  (_viewAtLeft != nil &&  [_viewAtLeft isEqual:subController.view]) {
			if  (_viewAtLeft2 == nil) {
				if (_viewAtRight == nil){					
					[subController.view setFrame:CGRectMake(SLIDE_VIEWS_START_X_POS, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
				}
				else{
					[subController.view setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
					 [_viewAtRight setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION + subController.view.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
				}
			}
			else if  (_viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION || _viewAtLeft.frame.origin.x == SLIDE_VIEWS_START_X_POS) {
				[subController.view setFrame:CGRectMake(subController.view.frame.origin.x, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
			}
			else {
				if  (_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width == self.view.frame.size.width) {
					[subController.view setFrame:CGRectMake(self.view.frame.size.width - subController.view.frame.size.width, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
				}else{
					[subController.view setFrame:CGRectMake (_viewAtLeft2.frame.origin.x + _viewAtLeft2.frame.size.width, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
				}
			}
		}
		else if(!isViewOutOfScreen){
			[subController.view setFrame:CGRectMake(subController.view.frame.origin.x, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
		}
		else {
			[subController.view setFrame:CGRectMake(self.view.frame.size.width, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
		}
		
	}
	for (UIViewController* subController in self.childViewControllers) {
		[subController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration]; 		
		if (!( (_viewAtRight != nil &&  [_viewAtRight isEqual:subController.view]) ||  (_viewAtLeft != nil &&  [_viewAtLeft isEqual:subController.view]) ||  (_viewAtLeft2 != nil &&  [_viewAtLeft2 isEqual:subController.view]))) {
			[[subController view] setHidden:TRUE];		
		}
		
	}       	
	
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {	
	for (UIViewController* subController in self.childViewControllers) {
		[subController didRotateFromInterfaceOrientation:fromInterfaceOrientation];                
	}
	if  (_viewAtLeft !=nil) {
		 [_viewAtLeft setHidden:FALSE];
	}
	if  (_viewAtRight !=nil) {
		 [_viewAtRight setHidden:FALSE];
	}	
	if  (_viewAtLeft2 !=nil) {
		 [_viewAtLeft2 setHidden:FALSE];
	}	
}



@end
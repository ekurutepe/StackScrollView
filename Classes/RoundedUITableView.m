//
//  RoundedUITableView.m
//  RoundedTableView
//
//  Created by Jeremy Collins on 1/7/10.
//  Copyright 2010 Beetlebug Software, LLC. All rights reserved.
//
//	From: https://github.com/beetlebugorg/RoundedUITableView
//
//	Copyright (C) 2011 by Jeremy Collins
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

#import "RoundedUITableView.h"
#import <QuartzCore/QuartzCore.h>


@implementation RoundedUITableViewMask


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
    }
    
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat cornerRadius = 10.0;
    CGFloat minx = CGRectGetMinX(rect);
    CGFloat midx = CGRectGetMidX(rect);
    CGFloat maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect);
    CGFloat midy = CGRectGetMidY(rect);
    CGFloat maxy = CGRectGetMaxY(rect);
    
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, cornerRadius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, cornerRadius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, cornerRadius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, cornerRadius);
    CGContextClosePath(context);
    CGContextFillPath(context);
}


- (void)dealloc {
    [super dealloc];
}


@end



@implementation RoundedUITableView


- (void)setupView {
    mask = [[RoundedUITableViewMask alloc] initWithFrame:CGRectZero]; 
    self.layer.mask = mask.layer;
    self.layer.cornerRadius = 10;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;    
}


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self setupView];
    }
	
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
		[self setupView];
    }
    
    return self;
}


- (void)adjustMask {
    // Re-calculate the size of the mask to account for adding/removing rows.
    CGRect frame = mask.frame;
    if(self.contentSize.height > self.frame.size.height) {
    	frame.size = self.contentSize;
    } else {
        frame.size = self.frame.size;
    }
    mask.frame = frame;
	
    [mask setNeedsDisplay];
    [self setNeedsDisplay];
}


- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [super deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self adjustMask];
}


- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [super insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self adjustMask];
}


- (void)reloadData {
    [super reloadData];
    [self adjustMask];
}


- (void)dealloc {
    [mask release];
    [super dealloc];
}


@end
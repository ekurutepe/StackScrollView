//
//  StackScrollViewAppDelegate.h
//  StackScrollView
//
//  Created by Reefaq on 2/24/11.
//  Copyright 2011 raw engineering . All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface StackScrollViewAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	RootViewController *rootViewController;
}

+ (StackScrollViewAppDelegate *) instance;

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) RootViewController *rootViewController;

@end


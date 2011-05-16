//
//  DataViewController.h
//  StackScrollView
//
//  Created by Reefaq on 2/24/11.
//  Copyright 2011 raw engineering . All rights reserved.
//

#import <UIKit/UIKit.h>

@class RoundedUITableView;

@interface DataViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	RoundedUITableView*  _tableView;
	
	NSArray *tweets;
	NSDateFormatter *formatter;
}

- (id)initWithFrame:(CGRect)frame squareCorners:(BOOL)squareCorners;


@property(nonatomic, retain) RoundedUITableView* tableView;

@end

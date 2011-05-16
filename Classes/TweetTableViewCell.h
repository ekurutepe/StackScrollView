//
//  TweetTableViewCell.h
//  StackScrollView
//
//  Created by Aaron Brethorst on 5/15/11.
//  Copyright 2011 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetTableViewCell : UITableViewCell
{
	UIImageView *imageView;
	UILabel *authorLabel;
	UILabel *tweetLabel;
	UILabel *timestampLabel;
}
@property(nonatomic,retain) UIImageView *imageView;
@property(nonatomic,retain) UILabel *authorLabel;
@property(nonatomic,retain) UILabel *tweetLabel;
@property(nonatomic,retain) UILabel *timestampLabel;

+ (int)heightForTweetWithText:(NSString*)tweetText;

@end

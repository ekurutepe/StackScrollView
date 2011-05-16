//
//  TweetTableViewCell.m
//  StackScrollView
//
//  Created by Aaron Brethorst on 5/15/11.
//  Copyright 2011 Structlab LLC. All rights reserved.
//

#import "TweetTableViewCell.h"

@implementation TweetTableViewCell
@synthesize imageView, authorLabel, tweetLabel, timestampLabel;

+ (int)heightForTweetWithText:(NSString*)tweetText
{
	CGFloat height = 0;
	height += 12; // top padding.
	height += 18; // author label.
	height += 5;  // padding between author and tweet.
	
	CGSize tweetTextSize = [tweetText sizeWithFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]] constrainedToSize:CGSizeMake(390, 10000) lineBreakMode:UILineBreakModeWordWrap];
	
	height += tweetTextSize.height;
	height += 12; // bottom padding.
	
	return (int)height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
	{
		self.opaque = YES;
		
		CGFloat color = (247.f / 255.f);
		self.contentView.backgroundColor = [UIColor colorWithRed:color green:color blue:color alpha:1.f];
		
		imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 48, 48)];
		[self.contentView addSubview:imageView];
		
		authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 12, 200, 18)];
		authorLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
		authorLabel.highlightedTextColor = [UIColor whiteColor];
		authorLabel.backgroundColor = self.contentView.backgroundColor;
		[self.contentView addSubview:authorLabel];
		
		tweetLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 35, 390, 40)];
		tweetLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
		tweetLabel.highlightedTextColor = [UIColor whiteColor];
		tweetLabel.numberOfLines = 0;
		tweetLabel.backgroundColor = self.contentView.backgroundColor;
		[self.contentView addSubview:tweetLabel];
	}
	
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	int h = self.frame.size.height; // truncating from float to int in order to prevent possibility of ugly sub-pixel rendering.
	
	h -= 47; // 47 is the sum of the non-tweet text elements we were considering in +heightForTweetWithText:
	
	CGRect tweetFrame = tweetLabel.frame;
	tweetFrame.size.height = h;
	tweetLabel.frame = tweetFrame;
}

- (void)dealloc
{
	self.imageView = nil;
	self.authorLabel = nil;
	self.tweetLabel = nil;
	self.timestampLabel = nil;
	
	[super dealloc];
}
@end

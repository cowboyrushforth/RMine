//
//  ActivityTableCell.h
//  RMine
//
//  Created by Scott Rushforth on 1/5/10.
//  Copyright 2010 0x7a69 Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ActivityTableCell : UITableViewCell {

	IBOutlet UILabel *authorName;
	IBOutlet UILabel *title;
	IBOutlet UILabel *description;
	IBOutlet UIImageView *imageView;
	IBOutlet UILabel *activityTime;
	NSThread *_thread;
	NSString *email;
	//IBOutlet UIView *viewForBackground;
	
}

@property(nonatomic, retain) IBOutlet UILabel *authorName;
@property(nonatomic, retain) IBOutlet UILabel *title;
@property(nonatomic, retain) IBOutlet UILabel *description;
@property(nonatomic, retain) IBOutlet UIImageView *imageView;
@property(nonatomic, retain) NSThread *_thread;
@property(nonatomic, retain) NSString *email;
@property(nonatomic, retain) IBOutlet UILabel *activityTime;
//@property(nonatomic, retain) UIView *viewForBackground;

- (void) showImage;
- (void) downloadImage;

@end

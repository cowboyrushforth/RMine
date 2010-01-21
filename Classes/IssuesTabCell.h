//
//  IssuesTabCell.h
//  RMine
//
//  Created by Scott Rushforth on 1/8/10.
//  Copyright 2010 0x7a69 Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IssuesTabCell : UITableViewCell {

	
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *issueNoLabel;
	IBOutlet UILabel *authorLabel;
	IBOutlet UILabel *timeLabel;
	IBOutlet UILabel *statusLabel;
	IBOutlet UILabel *projectNameLabel;
	
}

@property(nonatomic,retain) IBOutlet UILabel *titleLabel;
@property(nonatomic,retain) IBOutlet UILabel *issueNoLabel;
@property(nonatomic,retain) IBOutlet UILabel *authorLabel;
@property(nonatomic,retain) IBOutlet UILabel *timeLabel;
@property(nonatomic,retain) IBOutlet UILabel *statusLabel;
@property(nonatomic,retain) IBOutlet UILabel *projectNameLabel;


@end

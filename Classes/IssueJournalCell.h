//
//  IssueJournalCell.h
//  RMine
//
//  Created by Scott Rushforth on 1/6/10.
//  Copyright 2010 0x7a69 Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IssueJournalCell : UITableViewCell {

	IBOutlet UILabel *contentLabel;
	IBOutlet UILabel *timeLabel;
	IBOutlet UILabel *authorLabel;
	
}

@property(nonatomic,retain) IBOutlet UILabel *contentLabel;
@property(nonatomic,retain) IBOutlet UILabel *timeLabel;
@property(nonatomic,retain) IBOutlet UILabel *authorLabel;


@end

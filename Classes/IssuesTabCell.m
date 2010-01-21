//
//  IssuesTabCell.m
//  RMine
//
//  Created by Scott Rushforth on 1/8/10.
//  Copyright 2010 0x7a69 Inc.. All rights reserved.
//

#import "IssuesTabCell.h"


@implementation IssuesTabCell

@synthesize titleLabel;
@synthesize issueNoLabel;
@synthesize authorLabel;
@synthesize timeLabel;
@synthesize statusLabel;
@synthesize projectNameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end

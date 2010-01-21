//
//  ActivityUpdateTableController.h
//  RMine
//
//  Created by Scott Rushforth on 1/4/10.
//  Copyright 2010 0x7a69 Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ActivityUpdateTableController : UITableViewController {
	NSMutableArray *activityUpdatesArray;

}

@property(nonatomic,retain) NSMutableArray *activityUpdatesArray;

@end

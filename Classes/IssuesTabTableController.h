//
//  IssuesTabTableController.h
//  RMine
//
//  Created by Scott Rushforth on 1/6/10.
//  Copyright 2010 0x7a69 Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IssuesTabTableController : UITableViewController {
	
	
	NSMutableArray *issuesArray;

}

@property(nonatomic,retain) NSMutableArray *issuesArray;

@end

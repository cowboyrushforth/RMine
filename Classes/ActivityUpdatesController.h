//
//  ActivityUpdatesController.h
//  RMine
//
//  Created by Scott Rushforth on 1/4/10.
//  Copyright 0x7a69 Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityUpdateTableController.h"


@interface ActivityUpdatesController : UINavigationController {
	
	ActivityUpdateTableController *activityUpdateTableController;
	UIBarButtonItem *refreshButton;
	UIBarButtonItem *createButton;
	UIActivityIndicatorView *loading;
	UIBarButtonItem *statusInd;
	
	
}

@property(nonatomic,retain) ActivityUpdateTableController *activityUpdateTableController;
@property(nonatomic,retain) UIBarButtonItem *refreshButton;
@property(nonatomic,retain) UIBarButtonItem *createButton;
@property(nonatomic,retain) UIActivityIndicatorView *loading;
@property(nonatomic,retain) UIBarButtonItem *statusInd;


- (void) appendActivity:(NSManagedObjectID*)toid;
- (void) startRefresh;
- (void) refreshButtonPressed;
- (void) createNewIssue;
@end



//
//  IssuesTabController.h
//  RMine
//
//  Created by Scott Rushforth on 1/6/10.
//  Copyright 2010 0x7a69 Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IssuesTabTableController.h"

@interface IssuesTabController : UINavigationController {

	IssuesTabTableController *ittController; 
	UIBarButtonItem *refreshButton;
	UIBarButtonItem *createButton;
	UIActivityIndicatorView *loading;
	UIBarButtonItem *statusInd;
}

@property(nonatomic,retain) IssuesTabTableController *ittController;
@property(nonatomic,retain) UIBarButtonItem *refreshButton;
@property(nonatomic,retain) UIBarButtonItem *createButton;
@property(nonatomic,retain) UIActivityIndicatorView *loading;
@property(nonatomic,retain) UIBarButtonItem *statusInd;

- (void) appendIssue:(NSManagedObjectID*)toid;
- (void) startRefresh;
- (void) refreshButtonPressed;
- (void) createNewIssue;
@end
//
//  IssuesTabController.m
//  RMine
//
//  Created by Scott Rushforth on 1/6/10.
//  Copyright 2010 0x7a69 Inc.. All rights reserved.
//

#import "IssuesTabController.h"
#import "RMineAppDelegate.h"
#import "RMAPI.h"


@implementation IssuesTabController

@synthesize ittController;
@synthesize refreshButton;
@synthesize createButton;
@synthesize loading;
@synthesize statusInd;



- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSLog(@"IssuesTabController::viewDidLoad()");
	
	self.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	ittController = [[IssuesTabTableController alloc] init];
	ittController.title = @"Issues";
	CGRect frame = CGRectMake(10.0, 10.0, 20.0, 20.0);  
	loading = [[UIActivityIndicatorView alloc] initWithFrame:frame];  
	refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
																  target:self 
																  action:@selector(refreshButtonPressed)];
	ittController.navigationItem.leftBarButtonItem = refreshButton;
	createButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose 
																 target:self 
																 action:@selector(createNewIssue)];
	ittController.navigationItem.rightBarButtonItem = createButton;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Issue" inManagedObjectContext:[[RMineAppDelegate shared] managedObjectContext]];
	[request setEntity:entity];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	[request setReturnsObjectsAsFaults:NO];
	NSError *error = nil;
	ittController.issuesArray = [[[[RMineAppDelegate shared] managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];
	if (ittController.issuesArray == nil) {
		NSLog(@"Failed to populate issues!");
	} else {
		NSLog(@"%d initial issues", [ittController.issuesArray count]);
	}
	
	if(![ittController isViewLoaded]) {
		[self pushViewController:ittController animated:NO];
	}
	NSLog(@"about to getAllIssues");
	[self refreshButtonPressed];
	
}
-(void) refreshButtonPressed {
	[loading startAnimating]; 
	statusInd = [[UIBarButtonItem alloc] initWithCustomView:loading];   
	ittController.navigationItem.leftBarButtonItem = statusInd;
	[self performSelectorInBackground:@selector(startRefresh) withObject:nil];
}

-(void)startRefresh {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[RMAPI getAllIssues:self withSelector:@selector(appendIssue:)];
}
-(void)stopRefresh {
	ittController.navigationItem.leftBarButtonItem = refreshButton;
}

-(void)createNewIssue {
	NSLog(@"Not Finished Yet!");
}


- (void) appendIssue:(NSManagedObjectID*)toid {
	Issue *it = (Issue*)[[[RMineAppDelegate shared] managedObjectContext] objectWithID:toid];
	[ittController.issuesArray insertObject:it atIndex:0];
	//[ittController.issuesArray addObject:it];
	NSArray *indexPaths = [NSArray arrayWithObjects: 
						   [NSIndexPath indexPathForRow:0 inSection:0],
						   nil];
	[ittController.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
}

@end

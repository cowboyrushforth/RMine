//
//  ActivityUpdatesController.m
//  RMine
//
//  Created by Scott Rushforth on 1/4/10.
//  Copyright 0x7a69 Inc. 2010. All rights reserved.
//

#import "ActivityUpdatesController.h"
#import "TouchXML.h"
#import "ActivityUpdate.h"
#import "RMAPI.h"
#import "RMineAppDelegate.h"

@implementation ActivityUpdatesController


@synthesize activityUpdateTableController;
@synthesize refreshButton;
@synthesize createButton;
@synthesize loading;
@synthesize statusInd;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSLog(@"ActivityUpdatesController::viewDidLoad()");

	self.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	activityUpdateTableController = [[ActivityUpdateTableController alloc] init];
	activityUpdateTableController.title = @"Activity";
	CGRect frame = CGRectMake(10.0, 10.0, 20.0, 20.0);  
	loading = [[UIActivityIndicatorView alloc] initWithFrame:frame];  
	
	refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
																  target:self 
																  action:@selector(refreshButtonPressed)];
	activityUpdateTableController.navigationItem.leftBarButtonItem = refreshButton;
	createButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose 
																 target:self 
																 action:@selector(createNewIssue)];
	activityUpdateTableController.navigationItem.rightBarButtonItem = createButton;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ActivityUpdate" inManagedObjectContext:[[RMineAppDelegate shared] managedObjectContext]];
	[request setEntity:entity];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created_at" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	[request setReturnsObjectsAsFaults:NO];
	NSError *error = nil;
	activityUpdateTableController.activityUpdatesArray = [[[[RMineAppDelegate shared] managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];
	if (activityUpdateTableController.activityUpdatesArray == nil) {
		NSLog(@"Failed to populate activity!");
	} else {
		NSLog(@"%d initial activities", [activityUpdateTableController.activityUpdatesArray count]);
	}

	if(![activityUpdateTableController isViewLoaded]) {
		[self pushViewController:activityUpdateTableController animated:NO];
	}
	NSLog(@"about to getAllActivity");
	[self refreshButtonPressed];

}
-(void) refreshButtonPressed {
	[loading startAnimating]; 
	statusInd = [[UIBarButtonItem alloc] initWithCustomView:loading];   
	activityUpdateTableController.navigationItem.leftBarButtonItem = statusInd;
	[self performSelectorInBackground:@selector(startRefresh) withObject:nil];
}

-(void)startRefresh {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[RMAPI getAllActivity:self withSelector:@selector(appendActivity:)];
}
-(void)stopRefresh {
	activityUpdateTableController.navigationItem.leftBarButtonItem = refreshButton;
}

-(void)createNewIssue {
	NSLog(@"Not Finished Yet!");
}


- (void) appendActivity:(NSManagedObjectID*)toid {
	//NSLog(@"ADDING Activity!");
	ActivityUpdate *au = (ActivityUpdate*)[[[RMineAppDelegate shared] managedObjectContext] objectWithID:toid];
	[activityUpdateTableController.activityUpdatesArray insertObject:au atIndex:0];
	NSArray *indexPaths = [NSArray arrayWithObjects: 
						   [NSIndexPath indexPathForRow:0 inSection:0],
						   nil];
	[activityUpdateTableController.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.refreshButton = nil;
	self.createButton = nil;
	self.loading = nil;
	self.statusInd = nil;
	self.activityUpdateTableController = nil;
}


- (void)dealloc {
    [super dealloc];
	[refreshButton dealloc];
	[createButton dealloc];
	[loading dealloc];
	[statusInd dealloc];
	[activityUpdateTableController dealloc];
}

@end

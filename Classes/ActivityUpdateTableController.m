//
//  ActivityUpdateTableController.m
//  RMine
//
//  Created by Scott Rushforth on 1/4/10.
//  Copyright 2010 0x7a69 Inc.. All rights reserved.
//

#import "ActivityUpdateTableController.h"
#import "RMineAppDelegate.h"
#import "ActivityTableCell.h"
#import "ActivityUpdate.h"
#import "IssueController.h"

@implementation ActivityUpdateTableController
@synthesize activityUpdatesArray;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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
	self.activityUpdatesArray = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.activityUpdatesArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ActivityTableCell";
	ActivityTableCell *cell =  (ActivityTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil){
	//	NSLog(@"New Cell Made");
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (ActivityTableCell *)[nib objectAtIndex:0];
	//} else {
	//	NSLog(@"CELL RE_USED");
	} else {
	
		//NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
		//for (UIView *subview in subviews) {
		//	[subview removeFromSuperview];
		//	break;
		//}
		//[subviews release];
	}
	
	ActivityUpdate *au = (ActivityUpdate *)[activityUpdatesArray objectAtIndex:indexPath.row];
	[[cell title] setText:au.title];
	[[cell description] setText:au.content];
	[[cell authorName] setText:au.authorName];
	[[cell activityTime] setText:[RMineAppDelegate humanDate:[au created_at]]];
	

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//if this activity item has an issue id, load up issues controller
	NSNumber *iid = [(ActivityUpdate *)[activityUpdatesArray objectAtIndex:indexPath.row] issueId];
		if([iid intValue] > 0 ) {
			IssueController *issueController = [[IssueController alloc] initWithNibName:@"IssueController" bundle:nil iid:iid];
			[(UINavigationController*)[[[RMineAppDelegate shared] tabBarController] selectedViewController] pushViewController:issueController animated:YES];
			[issueController release];
		} else {
			UIAlertView *uiv = [[UIAlertView alloc] initWithTitle:@"Not Implemented" message:@"Revision Viewing Support Coming Soon!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[uiv show];
		}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 100.0; //returns floating point which will be used for a cell row height at specified row index
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath { 
    if((indexPath.row + (indexPath.section % 2))% 2 == 0)   {
        cell.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]; 
	}
	//ActivityUpdate *au = (ActivityUpdate *)[activityUpdatesArray objectAtIndex:indexPath.row];
	[(ActivityTableCell *)cell setEmail:[(ActivityUpdate *)[activityUpdatesArray objectAtIndex:indexPath.row] authorEmail]];
	if(![(ActivityTableCell *)cell email]) {
		[(ActivityTableCell *)cell setEmail:@"anonymous@gravatar.com"];
	}
	[(ActivityTableCell *)cell showImage];
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [super dealloc];
	[activityUpdatesArray release];
}


@end


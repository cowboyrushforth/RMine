//
//  IssuesTabTableController.m
//  RMine
//
//  Created by Scott Rushforth on 1/6/10.
//  Copyright 2010 0x7a69 Inc.. All rights reserved.
//

#import "IssuesTabTableController.h"
#import "Issue.h"
#import "IssueController.h"
#import "RMineAppDelegate.h"
#import "IssuesTabCell.h"


@implementation IssuesTabTableController

@synthesize issuesArray;

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
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 90.0; //returns floating point which will be used for a cell row height at specified row index
}



// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [issuesArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    	
    static NSString *CellIdentifier = @"IssuesTabCell";
	IssuesTabCell *cell =  (IssuesTabCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil){
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (IssuesTabCell *)[nib objectAtIndex:0];
	}
	
	Issue *ix = (Issue*)[issuesArray objectAtIndex:indexPath.row];
	cell.issueNoLabel.text = [NSString stringWithFormat:@"#%@", [ix.id	stringValue]];
	cell.titleLabel.text   = ix.title;
	cell.authorLabel.text  = ix.authorName;
	cell.timeLabel.text    = [RMineAppDelegate humanDate:[ix created_at]];
	cell.statusLabel.text  = ix.status;
	cell.projectNameLabel.text = [NSString stringWithFormat:@"  %@",ix.projectName];
	
    
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Issue *ix = (Issue*)[issuesArray objectAtIndex:indexPath.row];
	//if this activity item has an issue id, load up issues controller
	IssueController *issueController = [[IssueController alloc] initWithNibName:@"IssueController" bundle:nil iid:[ix id]];
	[(UINavigationController*)[[[RMineAppDelegate shared] tabBarController] selectedViewController] pushViewController:issueController animated:YES];
	[issueController release];
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
}


@end


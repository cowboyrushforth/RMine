//
//  IssueController.m
//  RMine
//
//  Created by Scott Rushforth on 1/5/10.
//  Copyright 2010 0x7a69 Inc.. All rights reserved.
//

#import "IssueController.h"
#import "RMAPI.h"
#import "GravatarLoader.h"
#import "RMineAppDelegate.h"
#import "IssueJournal.h"
#import "IssueJournalCell.h"
#import "TextViewController.h"


@implementation IssueController

@synthesize issue;
@synthesize issueId;
@synthesize titleLabel;
@synthesize contentLabel;
@synthesize imageView;
@synthesize authorName;
@synthesize issueCreatedAt;
@synthesize projectName;
@synthesize issueNumber;
@synthesize issueJournals;
@synthesize journalTable;
@synthesize loadFullContent;
@synthesize statusLabel;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil iid:(NSNumber*)iid {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		
		self.issueId = iid;
		
		
		
	}
    return self;
}




// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"IssueController Init:: ID: %@", issueId);
	
	if(issue = [RMAPI existingIssueForId:issueId]) {
		NSLog(@"we got issue!");
		[issue retain];
		[self populateIssue:nil];
		[self performSelectorInBackground:@selector(updateIssueStatus) withObject:nil];
	} else {
		NSLog(@"we got no issue yet! gettingz");
		[self performSelectorInBackground:@selector(getIssue) withObject:nil];
	}
	
	issueJournals = [RMAPI existingIssueJournalsForId:issueId];
	
	NSLog(@"%d existing issue journals.", [issueJournals count]);
	if([issueJournals count] > 0 ) {
		[self populateIssueJournals:nil];
	}
	
	journalTable.delegate = self;	
	[journalTable reloadData];
}
-(void)updateIssueStatus {
	NSAutoreleasePool *pool =  [[NSAutoreleasePool alloc] init];
	[RMAPI updateIssueStatus:issueId ob:self callback:@selector(finishUpdateIssueStatus:)];
}


-(void)getIssue {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[RMAPI populateIssueForId:issueId ob:self callback:@selector(populateIssue:)];
}
-(void)getIssueJournals {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[RMAPI populateIssueJournalsForId:issueId ob:self callback:@selector(appendIssueJournal:)];
	
}
 
-(void)finishUpdateIssueStatus:(NSString*)newStatus {
	NSLog(@"finishUpdateIssueStatus!");
	statusLabel.text = newStatus;
	[issue setStatus:newStatus];
}

-(void)populateIssue:(NSManagedObjectID*)toid {

	if(!(toid == nil)) {
		issue = (Issue*)[[[RMineAppDelegate shared] managedObjectContext] objectWithID:toid];
	}

	titleLabel.text = [issue title];	
	contentLabel.text = [RMAPI flattenHTML:[issue content]];
	authorName.text = [NSString stringWithFormat:@" %@", [issue authorName]];
	issueNumber.text = [NSString stringWithFormat:@"#%@", [[issue id] stringValue] ];
	issueCreatedAt.text = [RMineAppDelegate humanDate:[issue created_at]];
	projectName.text = [issue projectName];
	statusLabel.text = [issue status];

	if([[issue authorEmail] length] > 0) {
		[imageView setImage:[GravatarLoader fetchEmail:[issue authorEmail] withSize:60]];
	} else {
		[imageView setImage:[GravatarLoader fetchEmail:@"anonymous@gravatar.com" withSize:60]];

	}
	
	//always get the freshest journals AFTER we get the issue
	[self performSelectorInBackground:@selector(getIssueJournals) withObject:nil];
}
-(void)populateIssueJournals:(NSArray *)ijs {
	NSLog(@"at populate issue journals");
}

- (void) appendIssueJournal:(NSManagedObjectID*)toid {
	NSLog(@"appending journal issue!");
	IssueJournal *ij = (IssueJournal*)[[[RMineAppDelegate shared] managedObjectContext] objectWithID:toid];
//	[issueJournals insertObject:ij atIndex:0];
	[issueJournals addObject:ij];
	NSArray *indexPaths = [NSArray arrayWithObjects: 
						   [NSIndexPath indexPathForRow:([issueJournals count] - 1) inSection:0],
						   nil];
	[journalTable insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
}
-(void)stopRefresh {
	//activityUpdateTableController.navigationItem.leftBarButtonItem = refreshButton;
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
}

- (IBAction)fullContentPressed:(id)sender {
	
	TextViewController *tvController = [[TextViewController alloc] initWithNibName:@"TextViewController" bundle:nil];
	
	NSString *html = [NSString stringWithFormat:@"<html><body style='background-color: #ccc;'> \
					  <span style='font-family: Helvetica; font-size: 45%; color: black;'>%@</span></body></html>", 
					  [issue.content stringByReplacingOccurrencesOfString:@"\r\n" withString:@"<br/>"]];
	
	
	[(UINavigationController*)[[[RMineAppDelegate shared] tabBarController] selectedViewController] pushViewController:tvController animated:YES];
	[tvController.webView loadHTMLString:html baseURL:[NSURL URLWithString:@"/"]];
	[tvController.titleLabel setText:[NSString stringWithFormat:@"%@, %@ said:", [RMineAppDelegate humanDate:issue.created_at], issue.authorName ]];
	[tvController release];
	 
}


//table crap
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	IssueJournal *ij = (IssueJournal*)[issueJournals objectAtIndex:indexPath.row];
	TextViewController *tvController = [[TextViewController alloc] initWithNibName:@"TextViewController" bundle:nil];
	
	NSString *html = [NSString stringWithFormat:@"<html><body style='background-color: #ccc;'> \
	 <span style='font-family: Helvetica; font-size: 45%; color: black;'>%@</span></body></html>",
					  [ij.content stringByReplacingOccurrencesOfString:@"\r\n" withString:@"<br/>"]];
	
	//NSLog(@"content should be set to: %@", foobar);
	
	[(UINavigationController*)[[[RMineAppDelegate shared] tabBarController] selectedViewController] pushViewController:tvController animated:YES];
	[tvController.webView loadHTMLString:html baseURL:[NSURL URLWithString:@"/"]];
	[tvController.titleLabel setText:[NSString stringWithFormat:@"%@, %@ said:", [RMineAppDelegate humanDate:ij.created_at], ij.authorName ]];
	[tvController release];


}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 80.0; 
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath { 
	if((indexPath.row + (indexPath.section % 2))% 2 == 0)   {
		cell.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]; 
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"IssueJournalCell";

	IssueJournalCell *cell =  (IssueJournalCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil){
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (IssueJournalCell *)[nib objectAtIndex:0];
	}
	
	IssueJournal *ij = (IssueJournal*)[issueJournals objectAtIndex:indexPath.row];
	cell.authorLabel.text = ij.authorName;
	cell.timeLabel.text = [RMineAppDelegate humanDate:ij.created_at];
	cell.contentLabel.text = [RMAPI flattenHTML:ij.content];
	
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [issueJournals count];
}

- (void)dealloc {
    [super dealloc];
}


@end

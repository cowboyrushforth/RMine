//
//  IssueController.h
//  RMine
//
//  Created by Scott Rushforth on 1/5/10.
//  Copyright 2010 0x7a69 Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Issue.h"


@interface IssueController : UIViewController <UITableViewDelegate> {

	NSNumber *issueId;
	Issue *issue;
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *contentLabel;
	IBOutlet UIImageView *imageView;
	IBOutlet UILabel *issueCreatedAt;
	IBOutlet UILabel *authorName;
	IBOutlet UILabel *issueNumber;
	IBOutlet UILabel *projectName;
	IBOutlet UITableView *journalTable;
	NSMutableArray *issueJournals;
	IBOutlet UIButton *loadFullContent;
	IBOutlet UILabel *statusLabel;
}



@property(nonatomic,retain) NSNumber *issueId;
@property(nonatomic,retain) Issue *issue;
@property(nonatomic,retain) IBOutlet UILabel *titleLabel;
@property(nonatomic,retain) IBOutlet UILabel *contentLabel;
@property(nonatomic,retain) IBOutlet UIImageView *imageView;
@property(nonatomic,retain) IBOutlet UILabel *issueCreatedAt;
@property(nonatomic,retain) IBOutlet UILabel *authorName;
@property(nonatomic,retain) IBOutlet UILabel *projectName;
@property(nonatomic,retain) IBOutlet UILabel *issueNumber;
@property(nonatomic,retain) NSMutableArray *issueJournals;
@property(nonatomic,retain) IBOutlet UITableView *journalTable;
@property(nonatomic,retain) IBOutlet UIButton *loadFullContent;
@property(nonatomic,retain) IBOutlet UILabel *statusLabel;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil iid:(NSNumber*)iid;
-(void)populateIssue:(NSManagedObjectID*)toid;
-(void)populateIssueJournals:(NSArray*)ijs;
-(void)appendIssueJournal:(NSManagedObjectID*)toid;
-(void)stopRefresh;
- (IBAction)fullContentPressed:(id)sender;
-(void)updateIssueStatus;
-(void)finishUpdateIssueStatus:(NSString*)newStatus;

@end

//
//  IssueJournal.h
//  RMine
//
//  Created by Scott Rushforth on 1/6/10.
//  Copyright 2010 0x7a69 Inc.. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Issue;

@interface IssueJournal :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * issueId;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * authorName;
@property (nonatomic, retain) NSString * md5hash;
@property (nonatomic, retain) NSString * authorEmail;
@property (nonatomic, retain) Issue * issue;

@end




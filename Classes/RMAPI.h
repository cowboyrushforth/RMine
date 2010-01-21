//
//  RMAPI.h
//  RMine
//
//  Created by Scott Rushforth on 1/4/10.
//  Copyright 2010 0x7a69 Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Issue.h"


@interface RMAPI : NSObject {

	
}

+ (void)getAllActivity:(id)anObject withSelector:(SEL)selector;
+ (void)getAllIssues:(id)anObject withSelector:(SEL)selector;
+(NSNumber*) getIssueIDFromUrl:(NSString*)url ;
+ (NSString *)flattenHTML:(NSString *)html;
+(Issue*)existingIssueForId:(NSNumber*)iid;
+(NSMutableArray*)existingIssueJournalsForId:(NSNumber*)iid;
+(void)populateIssueForId:(NSNumber*)iid  ob:(id)ob callback:(SEL)cb;
+(void)populateIssueJournalsForId:(NSNumber*)iid  ob:(id)ob callback:(SEL)cb;
+(void)updateIssueStatus:(NSNumber*)issueId ob:(id)ob callback:(SEL)cb;


//+ (void)getIssuesForProject:(Project *)project;

@end

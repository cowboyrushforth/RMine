// 
//  ActivityUpdate.m
//  RMine
//
//  Created by Scott Rushforth on 1/5/10.
//  Copyright 2010 0x7a69 Inc.. All rights reserved.
//

#import "ActivityUpdate.h"
#import "RMineAppDelegate.h"


@implementation ActivityUpdate 

@dynamic authorEmail;
@dynamic content;
@dynamic created_at;
@dynamic title;
@dynamic issueId;
@dynamic authorName;
@dynamic md5hash;
@dynamic url;
@dynamic issue;

/* im just not sure this is working how i want.. */
/*
- (BOOL)validateForInsert:(NSError **)error {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ActivityUpdate" inManagedObjectContext:[[RMineAppDelegate shared] managedObjectContext]];
	[request setEntity:entity];
	NSLog(@"checking hash: %@", self.md5hash);
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"md5hash = %@", self.md5hash];
	[request setPredicate:predicate];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"issueID" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	[predicate release];
	[request setReturnsObjectsAsFaults:NO];
	[request setFetchLimit:2];
	
	NSArray *res = [[[RMineAppDelegate shared] managedObjectContext] executeFetchRequest:request error:nil];
	
	if([res count] ==	2) {
		return NO;
	} else {
		return YES;
	}
}
 */



@end

//
//  RMAPI.m
//  RMine
//
//  Created by Scott Rushforth on 1/4/10.
//  Copyright 2010 0x7a69 Inc.. All rights reserved.
//

#import "RMAPI.h"
#import "TouchXML.h"
#import "JSON.h"
#import "Issue.h"
#import "IssueJournal.h"
#import "RMineAppDelegate.h"


@implementation RMAPI

/* TODO - add user/password to settings, and fetch this key automagically.
 *        we will need their user/password anyways for posting issues.
 */

static NSString *redmine_address = @"YOUR.REDMINE_URL.COM";
static NSString *redmine_key = @"YOUR API KEY";

+(NSNumber*) getIssueIDFromUrl:(NSString*)url {
	
	NSArray *split = [NSArray alloc];
	split = [url componentsSeparatedByString:@"/"];
	
	NSString *lastpart = [NSString alloc];
	lastpart = [split objectAtIndex:4];
	split = [lastpart componentsSeparatedByString:@"#"];
	lastpart = [split objectAtIndex:0];
	
	NSNumber *tmpnum = [[NSNumber alloc] initWithInteger:[lastpart integerValue]];
	//returns 0 if there is no issue id (ie - a repository commit)
	return tmpnum;
	
}


+ (NSString *)flattenHTML:(NSString *)html {
	
    NSScanner *theScanner;
    NSString *text = nil;
	
    theScanner = [NSScanner scannerWithString:html];
	
    while ([theScanner isAtEnd] == NO) {
		
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ; 
		
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
		
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
				[ NSString stringWithFormat:@"%@>", text]
											   withString:@" "];
		
    } // while //
    
    return html;
	
}


+(void) getAllActivity:(id)anObject withSelector:(SEL)selector {
	
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@/activity.atom?key=%@", redmine_address, redmine_key]];
	NSLog(@"url is: %@", url);
	
    CXMLDocument *rssParser = [[[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil] autorelease];
	
	//have to prime this parser for atom
	NSDictionary *dictNameSpaceMappings = [[NSDictionary alloc]
										   initWithObjects:[NSArray 
															arrayWithObjects:@"http://www.w3.org/2005/Atom", nil]
										   forKeys:[NSArray arrayWithObjects:@"atom", nil]];
	
	NSArray *resultNodes = [rssParser nodesForXPath:@"/atom:feed/atom:entry"
								  namespaceMappings:dictNameSpaceMappings error:nil];
	
	NSLog(@"activity count: %d", [resultNodes count]);
	
	//iterate backwards - oldest to newest is the order we want to hand off in.
	for (CXMLElement *resultElement in [resultNodes reverseObjectEnumerator]) {
		
		
		NSString *ourHash = [NSString stringWithFormat:@"%@", [RMineAppDelegate md5Hash:[[[resultElement elementsForName:@"id"] objectAtIndex:0] stringValue]]];
		
		// Check To See If We Should Skip 
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"ActivityUpdate" inManagedObjectContext:[[RMineAppDelegate shared] managedObjectContext]];
		[request setEntity:entity];
		//NSLog(@"checking hash: %@", ourHash);
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"md5hash = %@", ourHash  ];
		[request setPredicate:predicate];
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"issueId" ascending:NO];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[request setSortDescriptors:sortDescriptors];
		[sortDescriptor release];
		[sortDescriptors release];
		[predicate release];
		//[request setReturnsObjectsAsFaults:NO];
		[request setFetchLimit:1];
		NSArray *res = [[[RMineAppDelegate shared] managedObjectContext] executeFetchRequest:request error:nil];
		if([res count] == 0) {  //we r uniq
			//NSLog(@"ADDING NEW ISSUE!");
			ActivityUpdate *au = (ActivityUpdate *)	[NSEntityDescription insertNewObjectForEntityForName:@"ActivityUpdate" inManagedObjectContext:[[RMineAppDelegate shared] managedObjectContext]];
			[au setContent:[RMAPI flattenHTML:[[[resultElement elementsForName:@"content"] objectAtIndex:0] stringValue]]];
			[au setTitle:[[[resultElement elementsForName:@"title"] objectAtIndex:0] stringValue]];
			[au setUrl:[[[resultElement elementsForName:@"id"] objectAtIndex:0] stringValue]];
			[au setMd5hash:ourHash];
			[au setIssueId:[RMAPI getIssueIDFromUrl:[[[resultElement elementsForName:@"id"] objectAtIndex:0] stringValue]]];
			
			
			//why this gives me a warning is a mystery wtf
			NSLog(@"issueid set: %@", [au issueId]);
			[au setAuthorName:[[[[[resultElement elementsForName:@"author"] objectAtIndex:0] elementsForName:@"name"] objectAtIndex:0] stringValue]];
			[au setAuthorEmail:[[[[[resultElement elementsForName:@"author"] objectAtIndex:0] elementsForName:@"email"] lastObject] stringValue]];
			
			//redmine atom date format
			NSDateFormatter *df = [[NSDateFormatter alloc] init];
			[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZ"];
			[au setCreated_at:[df dateFromString:[[[resultElement elementsForName:@"updated"] objectAtIndex:0] stringValue]]];
			
			
			[anObject performSelectorOnMainThread:selector withObject:[au objectID] waitUntilDone:YES];
		}
    }
	NSLog(@"DONE PARSIN!");
	[anObject performSelectorOnMainThread:@selector(stopRefresh) withObject:nil waitUntilDone:NO];
}

+(void) getAllIssues:(id)anObject withSelector:(SEL)selector {
	
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@/iphone/issues?key=%@", redmine_address, redmine_key]];
	NSLog(@"url is: %@", url);
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url
															  cachePolicy:NSURLRequestReturnCacheDataElseLoad
														  timeoutInterval:30];	
	
	NSLog(@"fetchin data");
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	
 	// Construct a String around the Data from the response
	NSString *jdata = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
	
	NSLog(@"gonna parse it");
	// Parse the JSON into an Object
	SBJSON *jsonParser = [SBJSON new];
	
	NSArray *issueList = [jsonParser objectWithString:jdata error:NULL];
	
	for(NSDictionary *rissue in [issueList reverseObjectEnumerator]) {
		
		//NSLog(@"got issue: %@", rissue);
		
		NSString *ourHash = [RMineAppDelegate md5Hash:[[rissue objectForKey:@"issue_id"] stringValue]];
		
		//NSLog(@"checking hash: %@", ourHash);
		
		// Check To See If We Should Skip 
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Issue" inManagedObjectContext:[[RMineAppDelegate shared] managedObjectContext]];
		[request setEntity:entity];
		//NSLog(@"checking hash: %@", ourHash);
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"md5hash = %@", ourHash  ];
		[request setPredicate:predicate];
		//NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
		//NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		//[request setSortDescriptors:sortDescriptors];
		//[sortDescriptor release];
		//[sortDescriptors release];
		[predicate release];
		//[request setReturnsObjectsAsFaults:NO];
		[request setFetchLimit:1];
		NSArray *res = [[[RMineAppDelegate shared] managedObjectContext] executeFetchRequest:request error:nil];
		//NSLog(@"already have: %d present", [res count]);

		if([res count] == 0) {  //we r uniq
			NSLog(@"ADDING NEW ISSUE!");
			
			
			NSDateFormatter *df = [[NSDateFormatter alloc] init];
			[df setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZ"];
			
			
			Issue *is = (Issue *)	[NSEntityDescription insertNewObjectForEntityForName:@"Issue" inManagedObjectContext:[[RMineAppDelegate shared] managedObjectContext]];
			[is setContent:[rissue objectForKey:@"issue_content"]];
			[is setId:[rissue objectForKey:@"issue_id"]];
			[is setTitle:[rissue objectForKey:@"issue_title"]];
			[is setAuthorName:[rissue objectForKey:@"author_name"]];
			[is setAuthorEmail:[rissue objectForKey:@"author_email"]];
			[is setUrl:[NSString stringWithFormat:@"http://%@/issues/%@", redmine_address, [rissue objectForKey:@"issue_id"]]];
			[is setCreated_at:[df dateFromString:[rissue objectForKey:@"issue_created_at"]]];
			[is setMd5hash:ourHash];
			[is setStatus:[rissue objectForKey:@"issue_status"]];
			[is setProjectName:[rissue objectForKey:@"project_name"]];
			//NSLog(@"adding issue: %@", is);
			[anObject performSelectorOnMainThread:selector withObject:[is objectID] waitUntilDone:YES];
			
		}
		
    }
	NSLog(@"DONE PARSIN (issues)!");
	[anObject performSelectorOnMainThread:@selector(stopRefresh) withObject:nil waitUntilDone:NO];
}



+(Issue*)existingIssueForId:(NSNumber*)iid {
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Issue" inManagedObjectContext:[[RMineAppDelegate shared] managedObjectContext]];
	[request setEntity:entity];
	//NSLog(@"checking hash: %@", ourHash);
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", iid  ];
	[request setPredicate:predicate];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	[predicate release];
	//[request setReturnsObjectsAsFaults:NO];
	[request setFetchLimit:1];
	NSArray *res = [[[RMineAppDelegate shared] managedObjectContext] executeFetchRequest:request error:nil];
	if([res count] == 0) {  //we r uniq
		return NO;
	} else {
		return [res objectAtIndex:0];
	}
}

+(NSMutableArray*)existingIssueJournalsForId:(NSNumber*)iid {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"IssueJournal" inManagedObjectContext:[[RMineAppDelegate shared] managedObjectContext]];
	[request setEntity:entity];
	//NSLog(@"checking hash: %@", ourHash);
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"issueId = %@", iid  ];
	[request setPredicate:predicate];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created_at" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	[predicate release];
	//[request setReturnsObjectsAsFaults:NO];
	//[request setFetchLimit:1];
	NSMutableArray *res = [[[[RMineAppDelegate shared] managedObjectContext] executeFetchRequest:request error:nil] mutableCopy];
	//if([res count] == 0) {  //we r uniq
	//	return NO;
	//} else {
	//	return [res objectAtIndex:0];
	//}
	return res;
}
+(void)populateIssueForId:(NSNumber*)iid ob:(id)ob callback:(SEL)cb {
	
	NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@/iphone/issue?issue_id=%@&key=%@", redmine_address, iid, redmine_key]];
	NSLog(@"url is: %@", url);
	
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
	
	
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url
															  cachePolicy:NSURLRequestReturnCacheDataElseLoad
														  timeoutInterval:30];	
	//[urlRequest addValue:[NSString stringWithFormat:@"Basic %@", dataStr] forHTTPHeaderField:@"Authorization"];
	
	NSLog(@"fetchin data");
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	
 	// Construct a String around the Data from the response
	NSString *jdata = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
	
	NSLog(@"gonna parse it");
	// Parse the JSON into an Object
	SBJSON *jsonParser = [SBJSON new];
	NSDictionary *feed = [jsonParser objectWithString:jdata error:NULL];
	NSDictionary *rissue = [feed objectForKey:@"issue"];
	NSDictionary *rproject = [feed objectForKey:@"project"];
	//NSArray *rjournals = [feed objectForKey:@"journals"];
	
	//redmine json date format
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZ"];
	
	Issue *is = (Issue *)	[NSEntityDescription insertNewObjectForEntityForName:@"Issue" inManagedObjectContext:[[RMineAppDelegate shared] managedObjectContext]];
	[is setContent:[rissue objectForKey:@"description"]];
	[is setId:iid];
	[is setTitle:[rissue objectForKey:@"subject"]];
	[is setAuthorName:[feed objectForKey:@"authorName"]];
	[is setAuthorEmail:[feed objectForKey:@"authorEmail"]];
	NSLog(@"b3");
	[is setUrl:[NSString stringWithFormat:@"http://%@/issues/%@", redmine_address, iid]];
	[is setCreated_at:[df dateFromString:[rissue objectForKey:@"created_on"]]];
	[is setMd5hash:[RMineAppDelegate md5Hash:[iid stringValue]]];
	[is setStatus:[feed objectForKey:@"issue_status"]];
	[is setProjectName:[rproject objectForKey:@"name"]];
	
	[ob performSelectorOnMainThread:cb withObject:[is objectID] waitUntilDone:YES];
}

+(void)populateIssueJournalsForId:(NSNumber *)iid ob:(id)ob callback:(SEL)cb {
	
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@/issues/%@.atom?key=%@", redmine_address, iid, redmine_key]];
	NSLog(@"url is: %@", url);
	
    CXMLDocument *rssParser = [[[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil] autorelease];
	
	//have to prime this parser for atom
	NSDictionary *dictNameSpaceMappings = [[NSDictionary alloc]
										   initWithObjects:[NSArray 
															arrayWithObjects:@"http://www.w3.org/2005/Atom", nil]
										   forKeys:[NSArray arrayWithObjects:@"atom", nil]];
	
	NSArray *resultNodes = [rssParser nodesForXPath:@"/atom:feed/atom:entry"
								  namespaceMappings:dictNameSpaceMappings error:nil];
	
	NSLog(@"xml journal count: %d", [resultNodes count]);
	
	//iterate backwards - oldest to newest is the order we want to hand off in.
	//for (CXMLElement *resultElement in [resultNodes reverseObjectEnumerator]) {
	for(CXMLElement *resultElement in resultNodes) {	
		
		NSString *ourHash = [NSString stringWithFormat:@"%@", [RMineAppDelegate md5Hash:[[[resultElement elementsForName:@"id"] objectAtIndex:0] stringValue]]];
		
		//Check To See If We Should Skip 
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"IssueJournal" inManagedObjectContext:[[RMineAppDelegate shared] managedObjectContext]];
		[request setEntity:entity];
		//NSLog(@"checking hash: %@", ourHash);
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"md5hash = %@", ourHash  ];
		[request setPredicate:predicate];
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created_at" ascending:NO];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[request setSortDescriptors:sortDescriptors];
		[sortDescriptor release];
		[sortDescriptors release];
		[predicate release];
		//[request setReturnsObjectsAsFaults:NO];
		[request setFetchLimit:1];
		NSArray *res = [[[RMineAppDelegate shared] managedObjectContext] executeFetchRequest:request error:nil];
		if([res count] == 0) {  //we r uniq
			NSLog(@"ADDING NEW JOURNAL ENTRY!");
			IssueJournal *ij = (IssueJournal *)	[NSEntityDescription insertNewObjectForEntityForName:@"IssueJournal" inManagedObjectContext:[[RMineAppDelegate shared] managedObjectContext]];
			[ij setContent:[[[resultElement elementsForName:@"content"] objectAtIndex:0] stringValue]];
			[ij setMd5hash:ourHash];
			[ij setIssueId:iid];
			[ij setAuthorName:[[[[[resultElement elementsForName:@"author"] objectAtIndex:0] elementsForName:@"name"] objectAtIndex:0] stringValue]];
			[ij setAuthorEmail:[[[[[resultElement elementsForName:@"author"] objectAtIndex:0] elementsForName:@"email"] lastObject] stringValue]];
			
			//redmine atom date format
			NSDateFormatter *df = [[NSDateFormatter alloc] init];
			[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZ"];
			[ij setCreated_at:[df dateFromString:[[[resultElement elementsForName:@"updated"] objectAtIndex:0] stringValue]]];
			
			
			[ob performSelectorOnMainThread:cb withObject:[ij objectID] waitUntilDone:YES];
		}
		
    }
	
	NSLog(@"DONE PARSIN!");
	[ob performSelectorOnMainThread:@selector(stopRefresh) withObject:nil waitUntilDone:NO];
}

+(void)updateIssueStatus:(NSNumber*)issueId ob:(id)ob callback:(SEL)cb {
	
	
	NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@/iphone/issue_status?issue_id=%@&key=%@", redmine_address, issueId, redmine_key]];	
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
	
	
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url
															  cachePolicy:NSURLRequestReturnCacheDataElseLoad
														  timeoutInterval:30];	
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	
 	// Construct a String around the Data from the response
	NSString *jdata = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];

	[ob performSelectorOnMainThread:cb withObject:jdata waitUntilDone:YES];
}


@end

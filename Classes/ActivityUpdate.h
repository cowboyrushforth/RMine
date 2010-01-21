//
//  ActivityUpdate.h
//  RMine
//
//  Created by Scott Rushforth on 1/5/10.
//  Copyright 2010 0x7a69 Inc.. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface ActivityUpdate :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * authorEmail;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * issueId;
@property (nonatomic, retain) NSString * authorName;
@property (nonatomic, retain) NSString * md5hash;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSManagedObject * issue;

@end




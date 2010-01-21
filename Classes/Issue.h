//
//  Issue.h
//  RMine
//
//  Created by Scott Rushforth on 1/5/10.
//  Copyright 2010 0x7a69 Inc.. All rights reserved.
//

#import <CoreData/CoreData.h>

@class ActivityUpdate;

@interface Issue :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * authorName;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSString * md5hash;
@property (nonatomic, retain) NSString * authorEmail;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * projectName;
@property (nonatomic, retain) NSSet* activityUpdates;
@property (nonatomic, retain) NSString * status;

@end


@interface Issue (CoreDataGeneratedAccessors)
- (void)addActivityUpdatesObject:(ActivityUpdate *)value;
- (void)removeActivityUpdatesObject:(ActivityUpdate *)value;
- (void)addActivityUpdates:(NSSet *)value;
- (void)removeActivityUpdates:(NSSet *)value;

@end


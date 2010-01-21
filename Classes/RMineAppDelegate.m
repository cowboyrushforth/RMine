//
//  RMineAppDelegate.m
//  RMine
//
//  Created by Scott Rushforth on 1/4/10.
//  Copyright 0x7a69 Inc. 2010. All rights reserved.
//

#import "RMineAppDelegate.h"
#import "ActivityUpdatesController.h"
#import "IssuesTabController.h"


@implementation RMineAppDelegate

static RMineAppDelegate *shared;

@synthesize window;
@synthesize tabBarController;
@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;
@synthesize gravatars;




//this is a shortcut to getting the delegate easier
//singleton
+ (id)shared;
{
    if (!shared) {
        [[RMineAppDelegate alloc] init];
    }
    return shared;
}
//md5
+ (NSString *)md5Hash:(NSString *)clearText
{	
	const char *cStr = [clearText UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			 result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			 result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			 ] lowercaseString];
	
} 

- (id)init
{
    if (shared) {
        [self autorelease];
        return shared;
    }
	if (![super init]) return nil;
	
	shared = self;
	//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if(!self.gravatars) {
		self.gravatars = [[NSMutableDictionary alloc] initWithCapacity:100];
	}
	return self;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	//NSManagedObjectContext *context = managedObjectContext;
	NSManagedObjectContext *context = [self managedObjectContext];
    if (!context) {
		NSLog(@"no managed object context in applicationdidfinishluahnching");
    }
	
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];  
    window.backgroundColor = [UIColor whiteColor]; 
    // Add the tab bar controller's current view as a subview of the window
    //[window addSubview:tabBarController.view];
	//get tab bar going
	tabBarController = [[UITabBarController alloc] init];         
	
	//get navigation controller for first tab going
	ActivityUpdatesController *activityUpdatesController = [[[ActivityUpdatesController alloc] init] autorelease];
	//ActivityUpdatesController.title = @"Activity"; 
	//issuesController.tabBarItem.image = [UIImage imageNamed:@"53-house.png"];
	
	IssuesTabController *issuesTabController = [[[IssuesTabController alloc] init] autorelease];
	issuesTabController.title = @"Issues";
	
	NSLog(@"controllers fired..");
	//and assign
	tabBarController.viewControllers = [NSArray arrayWithObjects:activityUpdatesController, issuesTabController, nil]; 
	tabBarController.delegate = self;
	
	[window addSubview:tabBarController.view];                                           
	[window makeKeyAndVisible]; 
	
}
//for core data
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}
//for core data
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}
//for core data
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	NSLog(@"persistent store coordinator: one");
    if (persistentStoreCoordinator != nil) {
		NSLog(@"returnin persisitant store");
        return persistentStoreCoordinator;
    }
	NSLog(@"ok setting sqlite path");
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"RMine.sqlite"]];
	NSString *strPath =  [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"RMine.sqlite"];
	NSLog(@"%@", storeUrl);
	NSError *error;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSNumber *clearcache = [[NSNumber alloc] initWithInteger:[defaults integerForKey:@"clearcache_preference"]];
	
	if([clearcache boolValue]) {
		NSLog(@"Clear Cache Setting Detected!!");
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSError *errorf;
		NSLog(@"Removing %@", strPath);
		[fileManager removeItemAtPath:strPath error:&errorf];
		//mark to not clear it again next time
		[defaults setBool:NO forKey:@"clearcache_preference"];	
	}
	
	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        NSLog(@"Persistent Storage Error: Re-Creating Database!");
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSError *error;
		NSLog(@"Removing %@", strPath);
		if([fileManager removeItemAtPath:strPath error:&error]) {
			[persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error];
		}
    }    
    return persistentStoreCoordinator;
}
//for core data
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}
+(NSString *)humanDate:(NSDate*)d {
    NSDate *todayDate = [NSDate date];
    double ti = [d timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    if(ti < 1) {
        return @"less than a minute ago";
    } else      if (ti < 60) {
        return @"less than a minute ago";
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d minutes ago", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        return[NSString stringWithFormat:@"%d hours ago", diff];
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        return[NSString stringWithFormat:@"%d days ago", diff];
    } else {
        return @"unknown";
    }   
}


/*
 // Optional UITabBarControllerDelegate method
 - (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
 }
 */

/*
 // Optional UITabBarControllerDelegate method
 - (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
 }
 */


-(void)applicationWillTerminate:(UIApplication *)application {
	NSError *error;
	//for core data to save changes
	//we need this here for sure
	if (managedObjectContext != nil) {
		if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle the error. 
			NSLog(@"core data error: %@, %@", error, [error userInfo]);
		} 
		
	}
}


- (void)dealloc {
    [tabBarController release];
    [window release];
	[managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    [super dealloc];
}

@end


//
//  RMineAppDelegate.h
//  RMine
//
//  Created by Scott Rushforth on 1/4/10.
//  Copyright 0x7a69 Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import "IASKAppSettingsViewController.h"



@interface RMineAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, IASKSettingsDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	//for core data
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	
	NSMutableDictionary *gravatars;
	UINavigationController *_appSettingsViewController;
	
	NSString *redmine_api_key;
	NSString *redmine_url;
	NSString *redmine_username;
	NSString *redmine_password;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
//for core data
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;
@property (nonatomic, retain) NSMutableDictionary *gravatars;
@property (nonatomic, retain) UINavigationController *appSettingsViewController;

@property (nonatomic, retain) NSString *redmine_api_key;
@property (nonatomic, retain) NSString *redmine_url;
@property (nonatomic, retain) NSString *redmine_username;
@property (nonatomic, retain) NSString *redmine_password;


+ (NSString *)md5Hash:(NSString *)clearText;
+ (id)shared;
+ (NSString *)humanDate:(NSDate*)d;

@end


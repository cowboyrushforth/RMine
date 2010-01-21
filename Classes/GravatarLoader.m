//#import <CommonCrypto/CommonDigest.h>
#import "GravatarLoader.h"
#import "RMineAppDelegate.h"
#import <CommonCrypto/CommonDigest.h>


@implementation GravatarLoader

//returns an image full with data for given email and size
+ (BOOL)cached:(NSString *)theEmail withSize:(NSInteger)theSize {
	
	//NSLog(@"checking: %@", theEmail);
	if(theEmail == nil) {
		return YES;
	}
	//trim email
	NSString *email = [[theEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];

	//make url
	NSString *url = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=%d", [RMineAppDelegate md5Hash:email], theSize];
	NSURL *gravatarURL = [NSURL URLWithString:url];
	
	
	if([[[RMineAppDelegate shared] gravatars] objectForKey:[RMineAppDelegate md5Hash:[gravatarURL absoluteString]]]) {
		return YES;
	} else {
		return NO;
	}
}

//returns an image full with data for given email and size
+ (void)loadEmail:(NSString *)theEmail withSize:(NSInteger)theSize {
	
	//trim email
	NSString *email = [[theEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
	//NSLog(@"going to try grab avatar for email: %@", email);
	NSData *gravatarData;
	

	//make url
	NSString *url = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=%d", [RMineAppDelegate md5Hash:email], theSize];
	NSURL *gravatarURL = [NSURL URLWithString:url];
	

	gravatarData = [NSData dataWithContentsOfURL:gravatarURL];
	
	[[[RMineAppDelegate shared] gravatars] setObject:gravatarData forKey:[RMineAppDelegate md5Hash:[gravatarURL absoluteString]]];
	
}

+ (UIImage*)fetchEmail:(NSString *)theEmail withSize:(NSInteger)theSize {
	NSString *email = [[theEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
	NSData *gravatarData;
	NSString *url = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=%d", [RMineAppDelegate md5Hash:email], theSize];
	NSURL *gravatarURL = [NSURL URLWithString:url];
	
	
	if(gravatarData = [[[RMineAppDelegate shared] gravatars] objectForKey:[RMineAppDelegate md5Hash:[gravatarURL absoluteString]]]) {
		return [UIImage imageWithData:gravatarData];
	} else {
			//we forgot to load this one, or something
		//load it
		gravatarData = [NSData dataWithContentsOfURL:gravatarURL];
		//store it
		[[[RMineAppDelegate shared] gravatars] setObject:gravatarData forKey:[RMineAppDelegate md5Hash:[gravatarURL absoluteString]]];
		//return it
			return [UIImage imageWithData:gravatarData];
	}
}


//returns only the url to get someones gravatar from
- (NSURL*)getURL:(NSString *)theEmail withSize:(NSInteger)theSize {
	//trim email
	if(theEmail == nil) {
		theEmail = @"anonymous@gravatar.com";
	}
	
	NSString *email = [[theEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
	
	if([email length] == 0) {
		email = @"anonymous@gravatar.com";
	}
	
	//make url
	NSString *url = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=%d", [RMineAppDelegate md5Hash:email], theSize];
	NSURL *gravatarURL = [NSURL URLWithString:url];
	return gravatarURL;
}

//returns an md5 hash string of the url, used for identifying cache
- (NSString*)getHashString:(NSString *)theEmail withSize:(NSInteger)theSize {
	return [RMineAppDelegate md5Hash:[[self getURL:theEmail withSize:theSize] absoluteString]];
}

- (void)dealloc {
	[super dealloc];
}

@end

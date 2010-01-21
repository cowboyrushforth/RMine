#import <UIKit/UIKit.h>


@interface GravatarLoader : NSObject {

}

+ (BOOL)cached:(NSString *)theEmail withSize:(NSInteger)theSize; 
+ (void)loadEmail:(NSString *)theEmail withSize:(NSInteger)theSize;
+ (UIImage*)fetchEmail:(NSString *)theEmail withSize:(NSInteger)theSize;

- (NSURL*)getURL:(NSString *)theEmail withSize:(NSInteger)theSize;
- (NSString*)getHashString:(NSString *)theEmail withSize:(NSInteger)theSize;

@end


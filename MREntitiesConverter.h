//http://discussions.apple.com/message.jspa?messageID=8064367#8064367
//fuck you apple, this is a shitty solution to an easy problem

@interface MREntitiesConverter : NSObject {
	NSMutableString* resultString;
}
@property (nonatomic, retain) NSMutableString* resultString;
- (NSString*)convertEntiesInString:(NSString*)s;
@end
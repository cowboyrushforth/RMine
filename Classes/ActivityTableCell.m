//
//  ActivityTableCell.m
//  RMine
//
//  Created by Scott Rushforth on 1/5/10.
//  Copyright 2010 0x7a69 Inc.. All rights reserved.
//

#import "ActivityTableCell.h"
#import "GravatarLoader.h"


@implementation ActivityTableCell
@synthesize authorName;
@synthesize title;
@synthesize description;
@synthesize imageView;
@synthesize _thread;
@synthesize email;
@synthesize activityTime;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showImage {
	@synchronized(self) {      
		if ([[NSThread currentThread] isCancelled]) return;
		
		[_thread cancel]; // Cell! Stop what you were doing!
		[_thread release];    
		_thread = nil;
        
		if ([GravatarLoader cached:email withSize:60]) { // If the image has already been downloaded.
			[self.imageView setImage:[GravatarLoader fetchEmail:email withSize:60]];
			self.imageView.hidden = NO;
		}
		else { // We need to download the image, get it in a seperate thread!      
			_thread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadImage) object:nil];
			[_thread start];
		}      
	}    
}

- (void)downloadImage {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (![[NSThread currentThread] isCancelled]) {
		
		[GravatarLoader loadEmail:email withSize:60];
		
		@synchronized(self) {
			if (![[NSThread currentThread] isCancelled]) {
				
				[self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:[GravatarLoader fetchEmail:email withSize:60] waitUntilDone:YES];                
				[self.imageView performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:YES];
				[self.imageView performSelectorOnMainThread:@selector(setHidden:) withObject:0 waitUntilDone:YES];
				
			}
		}
	}
	
	[pool release];
}

- (void)prepareForReuse {
	[super prepareForReuse];
	[_thread cancel]; // Cell! Stop what you were doing!
	[_thread release];    
	_thread = nil;
	self.imageView.hidden = YES;
}

- (void)dealloc {
    [super dealloc];
}


@end

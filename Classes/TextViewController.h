//
//  TextViewController.h
//  RMine
//
//  Created by Scott Rushforth on 1/6/10.
//  Copyright 2010 0x7a69 Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TextViewController : UIViewController {

	IBOutlet UILabel *titleLabel;
	IBOutlet UIWebView *webView;
	
}

@property(nonatomic,retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UIWebView *webView;

@end

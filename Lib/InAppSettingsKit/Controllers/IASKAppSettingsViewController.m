//
//  IASKAppSettingsViewController.m
//  http://www.inappsettingskit.com
//
//  Copyright (c) 2009:
//  Luc Vandal, Edovia Inc., http://www.edovia.com
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//  All rights reserved.
// 
//  It is appreciated but not required that you give credit to Luc Vandal and Ortwin Gentz, 
//  as the original authors of this code. You can give credit in a blog post, a tweet or on 
//  a info page of your app. Also, the original authors appreciate letting them know if you use this code.
//
//  This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//


#import "IASKAppSettingsViewController.h"
#import "IASKSettingsReader.h"
#import "IASKPSToggleSwitchSpecifierViewCell.h"
#import "IASKPSSliderSpecifierViewCell.h"
#import "IASKPSTextFieldSpecifierViewCell.h"
#import "IASKSwitch.h"
#import "IASKSlider.h"
#import "IASKSpecifier.h"
#import "IASKSpecifierValuesViewController.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

static NSString *kIASKCredits = @""; 

#define kIASKSpecifierValuesViewControllerIndex       0
#define kIASKSpecifierChildViewControllerIndex        1

#define kIASKCreditsViewWidth                         285

@interface IASKAppSettingsViewController ()
- (void)_textChanged:(id)sender;
@end

@implementation IASKAppSettingsViewController

@synthesize delegate = _delegate;
@synthesize currentIndexPath=_currentIndexPath;
@synthesize settingsReader = _settingsReader;
@synthesize file = _file;
@synthesize currentFirstResponder;
@synthesize showCreditsFooter = _showCreditsFooter;
@synthesize showDoneButton = _showDoneButton;

#pragma mark accessors
- (IASKSettingsReader*)settingsReader {
	if (!_settingsReader) {
		_settingsReader = [[IASKSettingsReader alloc] initWithFile:self.file];
	}
	return _settingsReader;
}

- (NSString*)file {
	if (!_file) {
		return @"Root";
	}
	return [[_file retain] autorelease];
}

- (void)setFile:(NSString *)file {
	if (file != _file) {
		[_file release];
		_file = [file copy];
	}
	
	self.settingsReader = nil; // automatically initializes itself
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ([super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // If set to YES, will display credits for InAppSettingsKit creators
        _showCreditsFooter = YES;
        
        // If set to YES, will add a DONE button at the right of the navigation bar
        _showDoneButton = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add views
    _viewList = [[NSMutableArray alloc] init];
    [_viewList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"IASKSpecifierValuesView", @"ViewName",nil]];
    [_viewList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"IASKAppSettingsView", @"ViewName",nil]];
}

- (void)viewWillAppear:(BOOL)animated {
    if (_tableView) {
        [_tableView reloadData];
    }
	
	if ([self.file isEqualToString:@"Root"]) {
        if (_showDoneButton) {
            UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                                        target:self 
                                                                                        action:@selector(dismiss:)];
            self.navigationItem.rightBarButtonItem = buttonItem;
            [buttonItem release];
		}        
		self.title = NSLocalizedString(@"Settings", @"");
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_viewList release];
    [_currentIndexPath release];
	[_file release];
	_file = nil;
	
	[currentFirstResponder release];
	currentFirstResponder = nil;
	
	_delegate = nil;

    [super dealloc];
}


#pragma mark -
#pragma mark Actions

- (IBAction)dismiss:(id)sender {
	if ([self.currentFirstResponder canResignFirstResponder]) {
		[self.currentFirstResponder resignFirstResponder];
	}
	
	if (self.delegate && [self.delegate conformsToProtocol:@protocol(IASKSettingsDelegate)]) {
		[self.delegate settingsViewControllerDidEnd:self];
	}
}

- (void)toggledValue:(id)sender {
    IASKSwitch *toggle    = (IASKSwitch*)sender;
    IASKSpecifier *spec   = [_settingsReader specifierForKey:[toggle key]];
    
    if ([toggle isOn]) {
        if ([spec trueValue] != nil) {
            [[NSUserDefaults standardUserDefaults] setObject:[spec trueValue] forKey:[toggle key]];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[toggle key]]; 
        }
    }
    else {
        if ([spec falseValue] != nil) {
            [[NSUserDefaults standardUserDefaults] setObject:[spec falseValue] forKey:[toggle key]];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[toggle key]]; 
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged object:[toggle key]];
}

- (void)sliderChangedValue:(id)sender {
    IASKSlider *slider = (IASKSlider*)sender;
    [[NSUserDefaults standardUserDefaults] setFloat:[slider value] forKey:[slider key]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged object:[slider key]];
}


#pragma mark -
#pragma mark UITableView Functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.settingsReader numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.settingsReader numberOfRowsForSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.settingsReader titleForSection:section];
}

/*- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (!_showCreditsFooter || section != [self.settingsReader numberOfSections]-1) return nil;
    
    // Show the credits only in the last section's footer
    return kIASKCredits;
}*/

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (!_showCreditsFooter || section != [self.settingsReader numberOfSections]-1) return nil;
    
    // Show the credits only in the last section's footer
    UILabel *credits = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, kIASKCreditsViewWidth, 0)] autorelease];
    [credits setOpaque:NO];
    [credits setNumberOfLines:0];
    [credits setFont:[UIFont systemFontOfSize:14.0f]];
    [credits setTextAlignment:UITextAlignmentRight];
    [credits setTextColor:[UIColor colorWithRed:77.0f/255.0f green:87.0f/255.0f blue:107.0f/255.0f alpha:1.0f]];
    [credits setShadowColor:[UIColor whiteColor]];
    [credits setShadowOffset:CGSizeMake(0, 1)];
    [credits setBackgroundColor:[UIColor clearColor]];
    [credits setText:kIASKCredits];
    [credits sizeToFit];
    
    UIView* view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kIASKCreditsViewWidth, credits.frame.size.height + 6 + 11)] autorelease];
    [view setBackgroundColor:[UIColor clearColor]];
    
    CGRect frame = credits.frame;
    frame.origin.y = 8;
    frame.origin.x = 16;
    frame.size.width = kIASKCreditsViewWidth;
    credits.frame = frame;
    
    [view addSubview:credits];
    [view sizeToFit];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (!_showCreditsFooter || section != [self.settingsReader numberOfSections]-1) return 0.0f;
    
    UIView* view = [self tableView:tableView viewForFooterInSection:section];
    if (view != nil) {
      return view.frame.size.height;
    }
    return -1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IASKSpecifier *specifier  = [self.settingsReader specifierForIndexPath:indexPath];
    NSString *key           = [specifier key];
    
    if ([[specifier type] isEqualToString:kIASKPSToggleSwitchSpecifier]) {
        IASKPSToggleSwitchSpecifierViewCell *cell = (IASKPSToggleSwitchSpecifierViewCell*)[tableView dequeueReusableCellWithIdentifier:[specifier type]];
        
        if (!cell) {
            cell = (IASKPSToggleSwitchSpecifierViewCell*) [[[NSBundle mainBundle] loadNibNamed:@"IASKPSToggleSwitchSpecifierViewCell" 
																					   owner:self 
																					 options:nil] objectAtIndex:0];
        }
        [[cell label] setText:[specifier title]];

		id currentValue = [[NSUserDefaults standardUserDefaults] objectForKey:key];
		BOOL toggleState;
		if (currentValue) {
			if ([currentValue isEqual:[specifier trueValue]]) {
				toggleState = YES;
			} else if ([currentValue isEqual:[specifier falseValue]]) {
				toggleState = NO;
			} else {
				toggleState = [currentValue boolValue];
			}
		} else {
			toggleState = [specifier defaultBoolValue];
		}
		[[cell toggle] setOn:toggleState];
		
        [[cell toggle] addTarget:self action:@selector(toggledValue:) forControlEvents:UIControlEventValueChanged];
        [[cell toggle] setKey:key];
        return cell;
    }
    else if ([[specifier type] isEqualToString:kIASKPSMultiValueSpecifier]) {
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kIASKPSMultiValueSpecifier] autorelease];
        [[cell textLabel] setText:[specifier title]];
        [[cell detailTextLabel] setText:[specifier titleForCurrentValue:[[NSUserDefaults standardUserDefaults] objectForKey:key] != nil ? 
										 [[NSUserDefaults standardUserDefaults] objectForKey:key] : [specifier defaultStringValue]]];
		
		// left align the value if the title is empty
		if (!specifier.title.length) {
			cell.textLabel.text = cell.detailTextLabel.text;
			cell.textLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
			cell.textLabel.textColor = cell.detailTextLabel.textColor;
			cell.detailTextLabel.text = nil;
		}
        //NSLog(@"[[NSUserDefaults standardUserDefaults] objectForKey:key]: %@", [[NSUserDefaults standardUserDefaults] objectForKey:key]);
        //NSLog(@"[specifier defaultValue]: %@", [specifier defaultValue]);
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        return cell;
    }
    else if ([[specifier type] isEqualToString:kIASKPSTitleValueSpecifier]) {
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kIASKPSTitleValueSpecifier] autorelease];
        [[cell textLabel] setText:[specifier title]];
        [[cell detailTextLabel] setText:[specifier defaultStringValue]];
        [cell setUserInteractionEnabled:NO];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        return cell;
    }
    else if ([[specifier type] isEqualToString:kIASKPSTextFieldSpecifier]) {
        IASKPSTextFieldSpecifierViewCell *cell = (IASKPSTextFieldSpecifierViewCell*)[tableView dequeueReusableCellWithIdentifier:[specifier type]];
        
        if (!cell) {
            cell = (IASKPSTextFieldSpecifierViewCell*) [[[NSBundle mainBundle] loadNibNamed:@"IASKPSTextFieldSpecifierViewCell" 
																					owner:self 
																				  options:nil] objectAtIndex:0];
        }
        [[cell label] setText:[specifier title]];
        [[cell textField] setText:[[NSUserDefaults standardUserDefaults] objectForKey:key] != nil ? 
		 [[NSUserDefaults standardUserDefaults] objectForKey:key] : [specifier defaultStringValue]];
        [[cell textField] setKey:key];
        [[cell textField] setDelegate:self];
        [[cell textField] addTarget:self action:@selector(_textChanged:) forControlEvents:UIControlEventEditingChanged];
        [[cell textField] setSecureTextEntry:[specifier isSecure]];
        [[cell textField] setKeyboardType:[specifier keyboardType]];
        [[cell textField] setAutocapitalizationType:[specifier autocapitalizationType]];
        [[cell textField] setAutocorrectionType:[specifier autoCorrectionType]];
        [[cell textField] setTextAlignment:UITextAlignmentLeft];
        [[cell textField] setReturnKeyType:UIReturnKeyDone];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        return cell;
    }
    else if ([[specifier type] isEqualToString:kIASKPSSliderSpecifier]) {
        IASKPSSliderSpecifierViewCell *cell = (IASKPSSliderSpecifierViewCell*)[tableView dequeueReusableCellWithIdentifier:[specifier type]];
		CGRect sliderFrame;
        
        if (!cell) {
            cell = (IASKPSSliderSpecifierViewCell*) [[[NSBundle mainBundle] loadNibNamed:@"IASKPSSliderSpecifierViewCell" 
																				 owner:self 
																			   options:nil] objectAtIndex:0];
        }
        
        sliderFrame             = [[cell slider] frame];
        sliderFrame.origin.x    = kIASKSliderNoImagesX;
        sliderFrame.size.width  = kIASKSliderNoImagesWidth;
        
        // Check if there are min and max images. If so, change the layout accordingly.
        if ([[specifier minimumValueImage] length] > 0 && [[specifier maximumValueImage] length] > 0) {
            // Both images
            [[cell minImage] setImage:[UIImage imageWithContentsOfFile:[_settingsReader pathForImageNamed:[specifier minimumValueImage]]]];
            [[cell maxImage] setImage:[UIImage imageWithContentsOfFile:[_settingsReader pathForImageNamed:[specifier maximumValueImage]]]];
            [[cell minImage] setHidden:NO];
            [[cell maxImage] setHidden:NO];
            sliderFrame.origin.x    = kIASKSliderBothImagesX;
            sliderFrame.size.width  = kIASKSliderBothImagesWidth;
        }
        else if ([[specifier minimumValueImage] length] > 0) {
            // Min image
            [[cell minImage] setImage:[UIImage imageWithContentsOfFile:[_settingsReader pathForImageNamed:[specifier minimumValueImage]]]];
            [[cell minImage] setHidden:NO];
            [[cell maxImage] setHidden:YES];
            sliderFrame.origin.x    = kIASKSliderBothImagesX;
            sliderFrame.size.width  = kIASKSliderOneImageWidth;
        }
        else if ([[specifier maximumValueImage] length] > 0) {
            // Max image
            [[cell maxImage] setImage:[UIImage imageWithContentsOfFile:[_settingsReader pathForImageNamed:[specifier maximumValueImage]]]];
            [[cell minImage] setHidden:YES];
            [[cell maxImage] setHidden:NO];
            sliderFrame.origin.x    = kIASKSliderNoImagesX;
            sliderFrame.size.width  = kIASKSliderOneImageWidth;
        }
        
        [[cell slider] setFrame:sliderFrame];
        [[cell slider] setMinimumValue:[specifier minimumValue]];
        [[cell slider] setMaximumValue:[specifier maximumValue]];
        [[cell slider] setValue:[[NSUserDefaults standardUserDefaults] objectForKey:key] != nil ? 
		 [[[NSUserDefaults standardUserDefaults] objectForKey:key] floatValue] : [[specifier defaultValue] floatValue]];
        [[cell slider] addTarget:self action:@selector(sliderChangedValue:) forControlEvents:UIControlEventValueChanged];
        [[cell slider] setKey:key];
        return cell;
    }
    else if ([[specifier type] isEqualToString:kIASKPSChildPaneSpecifier]) {
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kIASKPSChildPaneSpecifier] autorelease];
        [[cell textLabel] setText:[specifier title]];
        NSLog(@"[specifier file]: %@", [specifier file]);
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[specifier type]];
		
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[specifier type]] autorelease];
        }
        [[cell textLabel] setText:[specifier title]];
        return cell;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	IASKSpecifier *specifier  = [self.settingsReader specifierForIndexPath:indexPath];
	
	if ([[specifier type] isEqualToString:kIASKPSToggleSwitchSpecifier]) {
		return nil;
	} else {
		return indexPath;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IASKSpecifier *specifier  = [self.settingsReader specifierForIndexPath:indexPath];
    
    if ([[specifier type] isEqualToString:kIASKPSToggleSwitchSpecifier]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else if ([[specifier type] isEqualToString:kIASKPSMultiValueSpecifier]) {
        IASKSpecifierValuesViewController *targetViewController = [[_viewList objectAtIndex:kIASKSpecifierValuesViewControllerIndex] objectForKey:@"viewController"];
		
        if (targetViewController == nil) {
            // the view controller has not been created yet, create it and set it to our viewList array
            // create a new dictionary with the new view controller
            NSMutableDictionary *newItemDict = [NSMutableDictionary dictionaryWithCapacity:3];
            [newItemDict addEntriesFromDictionary: [_viewList objectAtIndex:kIASKSpecifierValuesViewControllerIndex]];	// copy the title and explain strings
            
            targetViewController = [[IASKSpecifierValuesViewController alloc] initWithNibName:@"IASKSpecifierValuesView" bundle:nil];
			
            // add the new view controller to the dictionary and then to the 'viewList' array
            [newItemDict setObject:targetViewController forKey:@"viewController"];
            [_viewList replaceObjectAtIndex:kIASKSpecifierValuesViewControllerIndex withObject:newItemDict];
            [targetViewController release];
            
            // load the view controll back in to push it
            targetViewController = [[_viewList objectAtIndex:kIASKSpecifierValuesViewControllerIndex] objectForKey:@"viewController"];
        }
        _currentIndexPath = indexPath;
        [targetViewController setCurrentSpecifier:specifier];
        targetViewController.settingsReader = self.settingsReader;
        [[self navigationController] pushViewController:targetViewController animated:YES];
    }
    else if ([[specifier type] isEqualToString:kIASKPSSliderSpecifier]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else if ([[specifier type] isEqualToString:kIASKPSTextFieldSpecifier]) {
		IASKPSTextFieldSpecifierViewCell *textFieldCell = (id)[tableView cellForRowAtIndexPath:indexPath];
		[textFieldCell.textField becomeFirstResponder];
    }
    else if ([[specifier type] isEqualToString:kIASKPSChildPaneSpecifier]) {
        IASKAppSettingsViewController *targetViewController = [[_viewList objectAtIndex:kIASKSpecifierChildViewControllerIndex] objectForKey:@"viewController"];
		
        if (targetViewController == nil) {
            // the view controller has not been created yet, create it and set it to our viewList array
            // create a new dictionary with the new view controller
            NSMutableDictionary *newItemDict = [NSMutableDictionary dictionaryWithCapacity:3];
            [newItemDict addEntriesFromDictionary: [_viewList objectAtIndex:kIASKSpecifierChildViewControllerIndex]];	// copy the title and explain strings
            
            targetViewController = [[IASKAppSettingsViewController alloc] initWithNibName:@"IASKAppSettingsView" bundle:nil];
			
            // add the new view controller to the dictionary and then to the 'viewList' array
            [newItemDict setObject:targetViewController forKey:@"viewController"];
            [_viewList replaceObjectAtIndex:kIASKSpecifierChildViewControllerIndex withObject:newItemDict];
            [targetViewController release];
            
            // load the view controll back in to push it
            targetViewController = [[_viewList objectAtIndex:kIASKSpecifierChildViewControllerIndex] objectForKey:@"viewController"];
        }
        _currentIndexPath = indexPath;
		targetViewController.file = specifier.file;
		targetViewController.title = specifier.title;
        targetViewController.showCreditsFooter = NO;
        [[self navigationController] pushViewController:targetViewController animated:YES];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}


#pragma mark -
#pragma mark UITextFieldDelegate Functions

- (void)_textChanged:(id)sender {
    IASKTextField *text = (IASKTextField*)sender;
    [[NSUserDefaults standardUserDefaults] setObject:[text text] forKey:[text key]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged object:[text key]];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [textField setTextAlignment:UITextAlignmentRight];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.currentFirstResponder = textField;

	viewFrameBeforeAnimation = self.view.frame;
	
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGRect viewFrame = viewFrameBeforeAnimation;
	viewFrame.size.height -= (orientation == UIInterfaceOrientationPortrait) ? PORTRAIT_KEYBOARD_HEIGHT : LANDSCAPE_KEYBOARD_HEIGHT;
	
	UITableViewCell *textFieldCell = (id)textField.superview.superview;
	NSIndexPath *textFieldIndexPath = [_tableView indexPathForCell:textFieldCell];
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
	[_tableView scrollToRowAtIndexPath:textFieldIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	self.currentFirstResponder = nil;
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrameBeforeAnimation];
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField setTextAlignment:UITextAlignmentLeft];
    [textField resignFirstResponder];
	return YES;
}

@end

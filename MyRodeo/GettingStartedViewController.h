//
//  GettingStartedViewController.h
//  MyRodeo
//
//  Created by mansoor shaikh on 27/12/13.
//  Copyright (c) 2013 ClientsSolution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface GettingStartedViewController : UIViewController
@property(nonatomic,retain) AppDelegate *appDelegate;
@property(nonatomic,retain) IBOutlet UIImageView *imgview;
@property(nonatomic,retain) IBOutlet UITextView *gettingstartedTextView;
@end

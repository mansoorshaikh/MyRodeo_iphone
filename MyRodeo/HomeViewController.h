//
//  HomeViewController.h;
//  MyRodeo
//
//  Created by mansoor shaikh on 19/12/13.
//  Copyright (c) 2013 ClientsSolution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface HomeViewController : UIViewController<UINavigationControllerDelegate>
{
    UIDeviceOrientation orientation;
}

@property(nonatomic,retain) IBOutlet UIButton *createRodeobtn,*lookupRodeobtn,*gettingstartedbtn,*settingsbtn,*aboutbtn,*helpbtn;
@property(nonatomic,retain) IBOutlet UIScrollView *scrollview;
@property(nonatomic,retain) IBOutlet UIImageView *bgimage;
@property(nonatomic,retain) AppDelegate *appDelegate;
@property(nonatomic,retain) IBOutlet UIImageView *logoimage;
-(IBAction)createRodeo;
-(IBAction)lookupRodeo;
-(IBAction)settingsOption;
-(IBAction)gettingStartedOption;
-(IBAction)aboutOption;
@end

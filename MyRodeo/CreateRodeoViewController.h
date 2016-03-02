//
//  CreateRodeoViewController.h
//  MyRodeo
//
//  Created by mansoor shaikh on 24/12/13.
//  Copyright (c) 2013 ClientsSolution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import <sqlite3.h>
@interface CreateRodeoViewController : UIViewController<UITextFieldDelegate,CLLocationManagerDelegate>
@property(nonatomic,retain) IBOutlet UIDatePicker *datepicker;
@property (nonatomic) sqlite3 *RodeoDB;
@property(nonatomic,retain) CLLocationManager *locationManager;
@property(nonatomic,retain) IBOutlet UIToolbar *toolbar;
@property(nonatomic,retain) IBOutlet UITextField *nameTextField,*locationTextField,*noofroundsTextFields,*rodeodateTextField,*noofplacesTextField,*locationTextField1;
@property(nonatomic,retain) AppDelegate *appDelegate;
@property(nonatomic,retain) IBOutlet UIButton *eventsbtn,*startrodeobtn,*saverodeobtn;
@property(nonatomic,retain) IBOutlet UIImageView *bgimage;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic,retain) NSMutableArray *rodeoList;
@property(nonatomic,readwrite) BOOL viewUp;
@property(nonatomic,retain) IBOutlet UILabel *rodeonameLabel,*rodeoAddressLabel,*rodeoDateLabel,*rodeo_noofrounds_Label;
-(IBAction)doneButtonPressed;
-(IBAction)eventsButtonClicked;


-(IBAction)startRodeo;
-(IBAction)saveRodeo;
@end

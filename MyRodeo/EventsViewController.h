//
//  EventsViewController.h
//  MyRodeo
//
//  Created by mansoor shaikh on 24/12/13.
//  Copyright (c) 2013 ClientsSolution. All rights reserved.
//
#import "AppDelegate.h"
#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "EventVO.h"
@interface EventsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIAlertViewDelegate>

@property (nonatomic) sqlite3 *database;
@property(nonatomic,retain) NSString *forRodeo,*rodeoid;
@property(nonatomic,retain) EventVO *selectedEvent;
@property(nonatomic,retain) AppDelegate *appDelegate;
@property(nonatomic,retain) IBOutlet UITableView *tblview;
@property(nonatomic,retain) IBOutlet UIImageView *bgimage;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic,retain) NSMutableArray *eventsArray,*eventnamesArray,*lookupEventsList,*eventsPickerArray,*usedEventsPickerArray,*eventSelectedPickerArray,*timedEventNamesArray,*scoredEventsNamesArray;
@property(nonatomic,retain) IBOutlet UIPickerView *pickerview;
@property(nonatomic,retain) IBOutlet UIToolbar *toolbar;
@property(nonatomic,retain) UITextField *currentTextField;
@property(nonatomic,readwrite) int index;
@property(nonatomic,readwrite) int tag;
@property(nonatomic,retain) UITextField *contestantTextField,*placesTextField;
@property(nonatomic,retain) UIToolbar* numberToolbar;
@property(nonatomic,retain) IBOutlet UIImageView *imgview;
@property(nonatomic,retain) UIBarButtonItem *editBarButton;
@property(nonatomic,readwrite) BOOL viewUp;
@property(nonatomic,readwrite) BOOL otherSelected,customEvent;

@end

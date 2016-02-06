//
//  EventsLookUpViewController.h
//  MyRodeo
//
//  Created by mansoor shaikh on 12/05/14.
//  Copyright (c) 2014 ClientsSolution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "Rodeo.h"
#import "CustomIOS7AlertView.h"
@class AppDelegate;
@interface EventsLookUpViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>
@property(nonatomic,retain) AppDelegate *appDelegate;
@property(nonatomic,retain) CustomIOS7AlertView *alertView;
@property(nonatomic,retain) Rodeo *selectedRodeo;
@property (nonatomic) sqlite3 *database;
@property(nonatomic,retain) IBOutlet UIImageView *bgimage;
@property(nonatomic,retain) NSString *rodeoid_,*selectedEvent,*eventType,*contestantsselected,*placesselected;
@property(nonatomic,retain) IBOutlet UITableView *tblview_;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator_;
@property(nonatomic,retain) NSMutableArray *eventsArray_,*EventNamesArray,*timedEventNamesArray,*scoredEventsNamesArray;
@property(nonatomic,retain) UITextField *currentTextField_;
@property(nonatomic,retain) UITextField *contestantTextField_,*placesTextField_;
@property(nonatomic,retain) UIBarButtonItem *editBarButton;

@end

//
//  SettingsViewController.h
//  MyRodeo
//
//  Created by mansoor shaikh on 25/12/13.
//  Copyright (c) 2013 ClientsSolution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SettingsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property(nonatomic,retain) AppDelegate *appDelegate;
@property(nonatomic,retain) IBOutlet UITableView *tblview;
@property(nonatomic,retain) NSMutableArray *settingsoptionsArray;
@property(nonatomic,retain) IBOutlet UIImageView *imgview;
@property(nonatomic,retain) NSString *currentSetting;
@end

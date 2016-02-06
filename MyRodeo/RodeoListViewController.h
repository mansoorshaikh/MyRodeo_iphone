//
//  RodeoListViewController.h
//  MyRodeo
//
//  Created by mansoor shaikh on 25/12/13.
//  Copyright (c) 2013 ClientsSolution. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;
#import <sqlite3.h>
#import "Rodeo.h"

@interface RodeoListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,retain) Rodeo *selectedRodeo;
@property(nonatomic,retain) IBOutlet UITableView *tblview;
@property(nonatomic,retain) IBOutlet UIImageView *imgview;
@property(nonatomic,retain) NSMutableArray *rodeosArray;
@property(nonatomic,retain) AppDelegate *appDelegate;
@property (nonatomic) sqlite3 *database;
@property(nonatomic,retain) NSMutableDictionary *rodeolist;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic,readwrite) int selectedRodeoId;

@end

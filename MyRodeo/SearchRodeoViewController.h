//
//  SearchRodeoViewController.h
//  MyRodeo
//
//  Created by mansoor shaikh on 26/12/13.
//  Copyright (c) 2013 ClientsSolution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Rodeo.h"
#import <sqlite3.h>
@interface SearchRodeoViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UIAlertViewDelegate>

@property (nonatomic) sqlite3 *database;

@property(nonatomic,retain) Rodeo *selectedRodeoToSync;

@property(nonatomic,retain) AppDelegate *appDelegate;

@property(nonatomic,retain) IBOutlet UITableView *tblview;

@property(nonatomic,retain) NSMutableArray *rodeosArray,*searchrodeosArray;

@property(nonatomic,retain) IBOutlet UISearchBar *searchbar;

@property(nonatomic,retain) IBOutlet UIImageView *imgview;

@property(nonatomic,readwrite) BOOL search;

@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

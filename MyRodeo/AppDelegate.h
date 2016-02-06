//
//  AppDelegate.h
//  MyRodeo
//
//  Created by mansoor shaikh on 19/12/13.
//  Copyright (c) 2013 ClientsSolution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Rodeo.h"
@class HomeViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property(nonatomic,retain) Rodeo *currentRodeo;
@property(nonatomic,retain) NSMutableArray *eventsList;
@property(nonatomic,retain) HomeViewController *hvc;
@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,readwrite) BOOL isfromLookup;
@property(nonatomic,retain) NSString *currentlocation;
@property(nonatomic,readwrite) BOOL isLandscapeOK;
@property(nonatomic,retain) NSString *isSaved;
@end

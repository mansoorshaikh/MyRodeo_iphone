//
//  EventDetailsViewController.h
//  MyRodeo
//
//  Created by mansoor shaikh on 27/12/13.
//  Copyright (c) 2013 ClientsSolution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <sqlite3.h>
#import "EventVO.h"
#import "Rodeo.h"
@interface EventDetailsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>
{
        UIDeviceOrientation orientation;
}
@property(nonatomic,retain) IBOutlet UILabel *roundNumberLabel,*roundNumberLabel_landscape;
@property(nonatomic,retain) IBOutlet UIImageView *bgimageview_landscape,*bgimageview_portrait;
@property(nonatomic) sqlite3 *database;
@property(nonatomic,retain) Rodeo *selectedRodeo;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator,*activityIndicator_landscape;
@property(nonatomic,retain) EventVO *eventVOSelected;
@property(nonatomic,retain) IBOutlet UILabel *scoreLabel,*timeLabel,*totalTimeLabel,*for1stinRoundLabel,*forLastInRoundLabel,*forfirstInAvgLabel,*forLastInAvgLabel,*scoreLabel_portrait,*timeLabel_portrait,*roundLabel,*roundLabel_Landscape;
@property(nonatomic,retain) NSString *eventidSelected,*oldContestantName,*eventtype,*sorttype,*sortText,*contStr;
@property(nonatomic,retain) UITextField *roundTextField,*avgTextField,*timeTextField,*totaltimeTextField,*
firstinroundTextField,*lastplaceinroundTextField,*firstinavgTextField,*lastplaceinavgTextField,*scoreTextField,*usernameTextField;
@property(nonatomic,retain) AppDelegate *appDelegate;
@property(nonatomic,retain) IBOutlet UITableView *tblview,*tblview_landscape;
@property(nonatomic,retain) IBOutlet UIView *mainPortraitView;
@property(nonatomic,retain) IBOutlet UIView *mainLandscapeView;
@property(nonatomic,retain) NSMutableArray *contestantsArray;
@property(nonatomic,retain) IBOutlet UIButton *sharebtn,*editbtn,*sortbtn,*addcontestantbtn,*sortBtn_Landscape;
@property(nonatomic,readwrite) bool isLandscape,contestantSaved;
@property(nonatomic,readwrite) int currentTextFieldTag,currentRound;
@property(nonatomic,retain) IBOutlet UIImageView *imgview,*imgviewLandscape;
@property(nonatomic,retain) UIToolbar* numberToolbar;
@property(nonatomic,retain) UITextField *currentNumberTextField,*lastContestantNameTextField,*lastTimeTextField;


-(IBAction)saveContestants;
-(IBAction)sortFunction;
@end;
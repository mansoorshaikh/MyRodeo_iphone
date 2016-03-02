//
//  EventDetailsViewController.m
//  MyRodeo
//
//  Created by mansoor shaikh on 27/12/13.
//  Copyright (c) 2013 ClientsSolution. All rights reserved.
//

#define kOFFSET_FOR_KEYBOARD 120.0

#import "EventDetailsViewController.h"
#import <objc/message.h>
#import "ContestantVO.h"
@interface EventDetailsViewController ()

@end

@implementation EventDetailsViewController
@synthesize mainPortraitView,imgview,roundTextField,timeTextField,totaltimeTextField,eventidSelected,eventVOSelected,selectedRodeo,contestantSaved,activityIndicator,activityIndicator_landscape,scoreTextField,oldContestantName,database;
@synthesize firstinroundTextField,lastplaceinroundTextField,firstinavgTextField,lastplaceinavgTextField;
@synthesize mainLandscapeView,tblview,contestantsArray,appDelegate,currentNumberTextField,sortBtn_Landscape;
@synthesize sharebtn,editbtn,sortbtn,addcontestantbtn,isLandscape,numberToolbar,avgTextField;
@synthesize currentTextFieldTag,roundNumberLabel,roundNumberLabel_landscape,sorttype,sortText,roundLabel,roundLabel_Landscape;
@synthesize bgimageview_landscape,bgimageview_portrait;
@synthesize scoreLabel,timeLabel,totalTimeLabel,for1stinRoundLabel,forLastInRoundLabel,forfirstInAvgLabel,forLastInAvgLabel;
@synthesize scoreLabel_portrait,timeLabel_portrait,currentRound,eventtype;
@synthesize lastContestantNameTextField,lastTimeTextField,usernameTextField,contStr,tblview_landscape,imgviewLandscape;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSString*)getDestPath
{
    NSString* srcPath = [[NSBundle mainBundle]pathForResource:@"Rodeo" ofType:@"sqlite"];
    NSArray* arrayPathComp = [NSArray arrayWithObjects:NSHomeDirectory(),@"Documents",@"Rodeo.sqlite", nil];
    
    NSString* destPath = [NSString pathWithComponents:arrayPathComp];
//    NSLog(@"src path:%@",srcPath);
  //  NSLog(@"dest path:%@",destPath);
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:destPath]!=YES) {
        NSError *error;
        
        if ([manager copyItemAtPath:srcPath toPath:destPath error:&error]!=YES) {
            NSLog(@"Failed");
            
            NSLog(@"Reason = %@",[error localizedDescription]);
        }
    }
    return  destPath;
}

-(void)viewDidAppear:(BOOL)animated{
        [self getContestantsList];
}

-(double)getAvg:(ContestantVO*)cvo{
    char *dbChars ;
    NSString *format_avg=@"%";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    double avg=0.00;
    for (int i=[eventVOSelected.currentround intValue]; i>=1; i--) {
                NSString *sqlStatement = [NSString stringWithFormat:@"select * from rounddetails where contestantid=%@ and round=%d",cvo.contestantid,i];
                sqlite3_stmt *compiledStatement;
                if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
                    while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                        if([eventVOSelected.eventType isEqualToString:@"timed"]){
                            dbChars = (char *)sqlite3_column_text(compiledStatement, 2);
                            if(dbChars!=nil)
                                avg += [[NSString stringWithFormat:[NSString stringWithFormat:@"%@.%@f",format_avg,[defaults objectForKey:@"timeformat"]],[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)] doubleValue]] doubleValue];
                        }else{
                            dbChars = (char *)sqlite3_column_text(compiledStatement, 1);
                            if(dbChars!=nil)
                                avg += [[NSString stringWithFormat:[NSString stringWithFormat:@"%@.%@f",format_avg,[defaults objectForKey:@"scoreformat"]],[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)] doubleValue]] doubleValue];
                        }
                    }
        }
    }
    return avg;
}

-(float)getTotalTime:(ContestantVO*)cvo{
    char *dbChars ;
    float avg=0;
    NSString* destPath = [self getDestPath];
    if([eventVOSelected.currentround intValue]>1){
        for (int i=[eventVOSelected.currentround intValue]; i>=1; i--) {
                NSString *sqlStatement = [NSString stringWithFormat:@"select * from rounddetails where eventid=%@ and round=%d and contestantname=\"%@\"",eventVOSelected.eventid,i,cvo.contestantname];
                sqlite3_stmt *compiledStatement;
                if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
                    while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                        if([eventVOSelected.eventType isEqualToString:@"timed"]){
                        dbChars = (char *)sqlite3_column_text(compiledStatement, 2);
                        if(dbChars!=nil){
                            avg += [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)] floatValue];
                        }
                        }else if([eventVOSelected.eventType isEqualToString:@"scored"]){
                            dbChars = (char *)sqlite3_column_text(compiledStatement, 1);
                            if(dbChars!=nil){
                                avg += [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)] floatValue];
                            }
                        }
                }
            }
        }
        if(avg==0){
           avg=[cvo.time floatValue];
        }
    }else{
        avg=[cvo.time floatValue];
    }
    return avg;
}

-(void)sortTimeEvent:(NSMutableArray*)array{
    [array sortUsingComparator:
     ^NSComparisonResult(ContestantVO *obj1, ContestantVO *obj2){
         if(([obj1.time floatValue]-[obj2.time floatValue])>0)
            return 1;
         else if(([obj1.time floatValue]-[obj2.time floatValue]<0))
            return -1;
         else
            return 0;
     }];
}


-(void)sortTimeEvent_Avg:(NSMutableArray*)array{
    [array sortUsingComparator:
     ^NSComparisonResult(ContestantVO *obj1, ContestantVO *obj2){
         if(([obj1.avg floatValue]-[obj2.avg floatValue])>0)
             return 1;
         else if(([obj1.avg floatValue]-[obj2.avg floatValue]<0))
             return -1;
         else
             return 0;
     }];
}


-(NSMutableArray*)sortTimeArrayList:(NSMutableArray*)contArray{
    NSMutableArray *sortnotZeroList=[[NSMutableArray alloc] init];
    NSMutableArray *sortZeroList=[[NSMutableArray alloc] init];
    
    for (int count=0; count<[contArray count]; count++) {
        ContestantVO *cvo=[contArray objectAtIndex:count];
        if([cvo.time floatValue]>0.00){
            [sortnotZeroList addObject:cvo];
        }else if([cvo.time floatValue]==0.00){
            [sortZeroList addObject:cvo];
        }
    }
    
    [self sortTimeEvent:sortnotZeroList];
    
    contArray=[[NSMutableArray alloc] init];
    for (int count=0; count<[sortnotZeroList count]; count++) {
        [contArray addObject:[sortnotZeroList objectAtIndex:count]];
    }
    
    for (int count=0; count<[sortZeroList count]; count++) {
        [contArray addObject:[sortZeroList objectAtIndex:count]];
    }
    
    return contArray;
}

-(NSMutableArray*)sortTimeArrayList_Avg:(NSMutableArray*)contArray{
    NSMutableArray *sortnotZeroList=[[NSMutableArray alloc] init];
    NSMutableArray *sortZeroList=[[NSMutableArray alloc] init];
    
    for (int count=0; count<[contArray count]; count++) {
        ContestantVO *cvo=[contArray objectAtIndex:count];
        if([cvo.avg floatValue]>0.00){
            [sortnotZeroList addObject:cvo];
        }else if([cvo.avg floatValue]==0.00){
            [sortZeroList addObject:cvo];
        }
    }
    
    [self sortTimeEvent_Avg:sortnotZeroList];
    
    contArray=[[NSMutableArray alloc] init];
    for (int count=0; count<[sortnotZeroList count]; count++) {
        [contArray addObject:[sortnotZeroList objectAtIndex:count]];
    }
    
    for (int count=0; count<[sortZeroList count]; count++) {
        [contArray addObject:[sortZeroList objectAtIndex:count]];
    }
    return contArray;
}


-(NSMutableArray*)sortScoredEvent:(NSMutableArray*)scoredArray{
    [scoredArray sortUsingComparator:
     ^NSComparisonResult(ContestantVO *obj1, ContestantVO *obj2){
         if(([obj2.score floatValue]-[obj1.score floatValue])>0)
         return 1;
         else if(([obj2.score floatValue]-[obj1.score floatValue])<0)
         return -1;
         else
         return 0;
     }];
    return scoredArray;
}

-(void)getContestantsList{
            char *dbChars ;
            NSString *sqlStatement = [NSString stringWithFormat:@"select * from contestants where eventid=%@",eventidSelected];
            NSLog(@"sqlStatement contestants : %@",sqlStatement);
            sqlite3_stmt *compiledStatement;
            int contestantcount=0;
            if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
                contestantsArray=[[NSMutableArray alloc] init];
                while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    contestantcount++;
                    ContestantVO *contestant=[[ContestantVO alloc] init];
                    dbChars = (char *)sqlite3_column_text(compiledStatement, 0);
                    if(dbChars!=nil)
                        contestant.contestantid=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
                    dbChars = (char *)sqlite3_column_text(compiledStatement, 1);
                    if(dbChars!=nil)
                        contestant.eventid=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                    dbChars = (char *)sqlite3_column_text(compiledStatement, 2);
                    if(dbChars!=nil)
                        contestant.contestantname=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                    [contestantsArray addObject:contestant];
                   
            }
        }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    sqlite3_stmt *compiledStatement_;
    NSString *format_avg=@"%";
            for (int count=0; count<[contestantsArray count]; count++) {
                ContestantVO *contestant=[contestantsArray objectAtIndex:count];
                sqlStatement = [NSString stringWithFormat:@"select * from rounddetails where contestantid=%@ and round=%d",contestant.contestantid,currentRound];
                NSLog(@"sqlStatement contestants : %@",sqlStatement);
                if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement_, NULL) == SQLITE_OK) {
                     while(sqlite3_step(compiledStatement_) == SQLITE_ROW) {
                    dbChars = (char *)sqlite3_column_text(compiledStatement_, 1);
                    if(dbChars!=nil)
                        contestant.score=[NSString stringWithFormat:[NSString stringWithFormat:@"%@.%@f",format_avg,[defaults objectForKey:@"scoreformat"]],[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement_, 1)] floatValue]];
                         
                    dbChars = (char *)sqlite3_column_text(compiledStatement_, 2);
                    if(dbChars!=nil)
                        contestant.time=[NSString stringWithFormat:[NSString stringWithFormat:@"%@.%@f",format_avg,[defaults objectForKey:@"timeformat"]],[[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement_, 2)] floatValue]];
                         if([eventVOSelected.eventType isEqualToString:@"timed"])
                            contestant.avg=[NSString stringWithFormat:[NSString stringWithFormat:@"%@.%@f",format_avg,[defaults objectForKey:@"timeformat"]],[self getAvg:contestant]];
                         else
                            contestant.avg=[NSString stringWithFormat:[NSString stringWithFormat:@"%@.%@f",format_avg,[defaults objectForKey:@"scoreformat"]],[self getAvg:contestant]];
                     }
                }
            }
    
    if(contestantcount==0){
        [self addContestantsToDB];
    }else{
        if([sorttype isEqualToString:@"Contestant Name"]){
           [self sortByContestantName];
        }else if([sorttype isEqualToString:@"Time"]){
            contestantsArray=[[NSMutableArray alloc] initWithArray:[self sortTimeArrayList:contestantsArray]];
        }
        else if([sorttype isEqualToString:@"Score"]){
            contestantsArray=[[NSMutableArray alloc] initWithArray:[self sortScoredEvent:contestantsArray]];
        }else if([sorttype isEqualToString:@"Average"]){
            if([eventVOSelected.eventType isEqualToString:@"timed"])
             contestantsArray = [[NSMutableArray alloc] initWithArray:[self sortTimeArrayList_Avg:contestantsArray]];
            else
             contestantsArray = [[NSMutableArray alloc] initWithArray:[self sortScoredAvgFunction:contestantsArray]];
        }
       
    }
    
    if(isLandscape){
        [self.tblview_landscape reloadData];
    }
    else{
        [self.tblview reloadData];
    }

}

- (NSUInteger)supportedInterfaceOrientations
{
       appDelegate.isLandscapeOK=YES;
       return UIInterfaceOrientationMaskAll;
}

-(void)popviewController{
    sqlite3_close(database);
    [self.navigationController popViewControllerAnimated:YES];
    if(contestantSaved==FALSE)
    [self saveContestants];
}


-(void)addContestantsToDB{
    sqlite3_stmt *statement;
    NSLog(@"[self getDestPath] = %@",[self getDestPath]);
    
    if (sqlite3_open([[self getDestPath] UTF8String], &database) == SQLITE_OK)
    {

    for (int count=0; count<[eventVOSelected.contestants intValue]; count++) {
        NSString *insertSQL;
        insertSQL = [NSString stringWithFormat:
                     @"insert into contestants (contestantname,eventid) VALUES (\"Contestant %d\",\"%@\")",(count+1),eventVOSelected.eventid];
        
        NSLog(@"insertSQL = %@",insertSQL);
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,
                           -1, &statement, NULL);
        NSNumber *menuID;

        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"record inserted");
            menuID = [NSDecimalNumber numberWithLongLong:sqlite3_last_insert_rowid(database)];
            for (int innercount=0; innercount<[selectedRodeo.numberofrounds intValue]; innercount++) {
                insertSQL = [NSString stringWithFormat:
                             @"insert into rounddetails (contestantid,time,round,position,score) VALUES (\"%@\",\"0.00\",\"%d\",\"%d\",\"0.00\")",menuID,(innercount+1),(innercount+1)];
                
                NSLog(@"insertSQL = %@",insertSQL);
                const char *insert_stmt = [insertSQL UTF8String];
                sqlite3_prepare_v2(database, insert_stmt,
                                   -1, &statement, NULL);
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    NSLog(@"record inserted");
                }
            }
        }
    }
    }
    [self getContestantsList];
}

-(IBAction)saveContestants{
    sqlite3_stmt *statement;
        NSString *insertSQL;
        for (int contestantid=0; contestantid<[contestantsArray count]; contestantid++) {
            ContestantVO *cvo=[contestantsArray objectAtIndex:contestantid];
            insertSQL = [NSString stringWithFormat:
                         @"update contestants set contestantname = \"%@\", position=%d, time=\"%@\", score=\"%@\" where round=\"%@\" and contestantid = %@",cvo.contestantname,contestantid+1,cvo.time,cvo.score,eventVOSelected.currentround,cvo.contestantid];
            
            NSLog(@"insertSQL = %@",insertSQL);
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(database, insert_stmt,
                               -1, &statement, NULL);
            
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"event detail contestant position updated");
            }else{
                NSLog(@"Error %s while preparing statement", sqlite3_errmsg(database));
            }
    }
    
    contestantSaved=TRUE;
}

- (sqlite3 *)getNewDb {
    sqlite3 *newDb = nil;
    if (sqlite3_open([[self getDestPath] UTF8String], &newDb) == SQLITE_OK) {
        sqlite3_busy_timeout(newDb, 1000);
    } else {
        sqlite3_close(newDb);
    }
    return newDb;
}

-(void)updateEventRound:(NSString*)updateType{
    sqlite3_stmt *statement;
    NSLog(@"[self getDestPath] = %@",[self getDestPath]);
    
        NSString *insertSQL;
        if([updateType isEqualToString:@"prev"]){
            insertSQL = [NSString stringWithFormat:
                         @"update events set currentround = %d where eventid = %@",[eventVOSelected.currentround intValue]-1,eventVOSelected.eventid];
        }else{
            insertSQL = [NSString stringWithFormat:
                         @"update events set currentround = %d where eventid = %@",[eventVOSelected.currentround intValue]+1,eventVOSelected.eventid];
        }
        
        NSLog(@"insertSQL = %@",insertSQL);
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,
                           -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE)
        {   
            NSLog(@"rodeo status updated to started");
        }else{
            NSLog(@"error msg %s",sqlite3_errmsg(database));
        }
    char *dbChars ;
    NSString* destPath = [self getDestPath];
        NSString *sqlStatement = [NSString stringWithFormat:@"select * from events where eventid=%@",eventVOSelected.eventid];
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                dbChars = (char *)sqlite3_column_text(compiledStatement, 1);
                if(dbChars!=nil)
                    eventVOSelected.currentround=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
        }
    }
}

- (void) threadStartAnimating:(id)data {
    if(isLandscape){
      [activityIndicator_landscape startAnimating];
    }else{
      [activityIndicator startAnimating];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    currentTextFieldTag=-1;
    contestantSaved=FALSE;
    self.tblview.delegate = self;
    self.tblview.dataSource = self;
    sortText=[[NSString alloc] init];
    [activityIndicator stopAnimating];
    [activityIndicator_landscape stopAnimating];
    roundLabel.text=@"Place\nRound";
    roundLabel_Landscape.text=@"Place\nRound";
    if(currentRound==0){
        currentRound=1;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    forLastInRoundLabel.text=[NSString stringWithFormat:@"For %@ in Round",eventVOSelected.places];
    forLastInAvgLabel.text=[NSString stringWithFormat:@"For %@ in Avg",eventVOSelected.places];
    
    if([eventVOSelected.eventType isEqualToString:@"timed"]){
        scoreLabel.text=@"Time";
        scoreLabel_portrait.text=@"Time";
    }else if([eventVOSelected.eventType isEqualToString:@"scored"]){
        scoreLabel.text=@"Score";
        scoreLabel_portrait.text=@"Score";
    }
    
    roundNumberLabel.text=[NSString stringWithFormat:@"Round %d",currentRound];
    roundNumberLabel_landscape.text=[NSString stringWithFormat:@"Round %d",currentRound];
    
    appDelegate=[[UIApplication sharedApplication] delegate];
    database=[self getNewDb];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    imgview.frame=CGRectMake(0, 0, width, height);
    imgviewLandscape.frame=CGRectMake(0, 0, height, width);
    
    imgviewLandscape.image=[UIImage imageNamed:@"innerbg_landscape.png"];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if(height==568){
            imgview.image=[UIImage imageNamed:@"innerbg.png"];
            [sortbtn setFrame:CGRectMake(140,460,60,40)];
            [sortBtn_Landscape setFrame:CGRectMake(230,240,80,30)];
        }else{
            imgview.image=[UIImage imageNamed:@"innerbg_.png"];
            [sortbtn setFrame:CGRectMake(140,500,60,40)];
            [sortBtn_Landscape setFrame:CGRectMake(230,300,80,30)];
        }

        [sharebtn.titleLabel setFont:[UIFont fontWithName:@"Segoe Print" size:14.0]];
        [editbtn.titleLabel setFont:[UIFont fontWithName:@"Segoe Print" size:14.0]];
        [sortbtn.titleLabel setFont:[UIFont fontWithName:@"Segoe Print" size:16.0]];
        [sortBtn_Landscape.titleLabel setFont:[UIFont fontWithName:@"Segoe Print" size:16.0]];
        [addcontestantbtn.titleLabel setFont:[UIFont fontWithName:@"Segoe Print" size:14.0]];
    }else{
         [sortbtn setFrame:CGRectMake((self.view.bounds.size.width/2)-75,self.view.bounds.size.height-120,150,40)];
        [sharebtn.titleLabel setFont:[UIFont fontWithName:@"Segoe Print" size:30.0]];
        [editbtn.titleLabel setFont:[UIFont fontWithName:@"Segoe Print" size:30.0]];
        [sortbtn.titleLabel setFont:[UIFont fontWithName:@"Segoe Print" size:35.0]];
        [sortBtn_Landscape.titleLabel setFont:[UIFont fontWithName:@"Segoe Print" size:35.0]];
        [addcontestantbtn.titleLabel setFont:[UIFont fontWithName:@"Segoe Print" size:30.0]];

    }
    
    [self.view addSubview:mainPortraitView];
    self.navigationController.navigationBar.hidden=NO;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        [backButton setFrame:CGRectMake(0,0,50,30)];
    else
        [backButton setFrame:CGRectMake(0,0,80,48)];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.userInteractionEnabled = YES;
    [backButton addTarget:self
                   action:@selector(popviewController)
         forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"backbtn.png"] forState:UIControlStateNormal];
    
    // ASSIGNING THE BUTTON WITH IMAGE TO BACK BAR BUTTON
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    backBarButton.title=@"Back";
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar.png"]];
    self.navigationController.navigationBar.translucent = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Segoe Print" size:18] forKey:NSFontAttributeName];
    }else{
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Segoe Print" size:30] forKey:NSFontAttributeName];
    }

    self.navigationItem.title=eventVOSelected.eventname;

    
    UIBarButtonItem *prevButton = [[UIBarButtonItem alloc] initWithTitle:@"Prev" style:UIBarButtonItemStyleBordered target:self action:@selector(prevClicked)];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextClicked)];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [nextButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:18], UITextAttributeFont,nil] forState:UIControlStateNormal];
        [prevButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:18], UITextAttributeFont,nil] forState:UIControlStateNormal];
    }
    else{
        [nextButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:30], UITextAttributeFont,nil] forState:UIControlStateNormal];
        [prevButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:30], UITextAttributeFont,nil] forState:UIControlStateNormal];
    }
    nextButton.tintColor=[UIColor whiteColor];
    prevButton.tintColor=[UIColor whiteColor];
    self.navigationItem.rightBarButtonItems = @[nextButton,prevButton];
    numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    contestantsArray=[[NSMutableArray alloc] init];
    
    if([eventVOSelected.currentround isEqualToString:@"0"]){
        [self updateEventRound:@"next"];
    }
   

}

-(void)prevClicked{
    if(currentRound==1){
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"My Rodeo"
                                                          message:@"No Previous Round Available."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    }else{
            currentTextFieldTag=-1;
            currentRound=currentRound-1;
            roundNumberLabel.text=[NSString stringWithFormat:@"Round %d",currentRound];
            roundNumberLabel_landscape.text=[NSString stringWithFormat:@"Round %d",currentRound];
            eventVOSelected.currentround=[NSString stringWithFormat:@"%d",currentRound];
            [self saveContestants];
            [self getContestantsList];
    }
}

-(void)nextClicked{
    if(currentRound==[selectedRodeo.numberofrounds intValue]){
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"My Rodeo"
                                                      message:@"No Next Round Available."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [message show];
    }else{
            currentTextFieldTag=-1;
            currentRound=currentRound+1;
            roundNumberLabel.text=[NSString stringWithFormat:@"Round %d",currentRound];
            roundNumberLabel_landscape.text=[NSString stringWithFormat:@"Round %d",currentRound];
            eventVOSelected.currentround=[NSString stringWithFormat:@"%d",currentRound];
            [self getContestantsList];
    }
}

-(void)cancelNumberPad{
    if([currentNumberTextField.text isEqualToString:@""] || [currentNumberTextField.text isEqualToString:@"0.00"] || [currentNumberTextField.text isEqualToString:@"0.0"] || [currentNumberTextField.text isEqualToString:@"0"])
    currentNumberTextField.text = @"0.00";
}

-(void)doneWithNumberPad{
    ContestantVO *cvo=[contestantsArray objectAtIndex:currentTextFieldTag-400];
    if([currentNumberTextField.text isEqualToString:@""]){
        [self getContestantsList];
        [currentNumberTextField resignFirstResponder];
    }else{
    NSString *format_avg=@"%";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [currentNumberTextField resignFirstResponder];
    
    NSString *defaultformatValue=@"";
    if([eventVOSelected.eventType isEqualToString:@"timed"]){
       defaultformatValue= [NSString stringWithFormat:[NSString stringWithFormat:@"%@.%@f",format_avg,[defaults objectForKey:@"timeformat"]],@"0.00"];
    }else{
        defaultformatValue= [NSString stringWithFormat:[NSString stringWithFormat:@"%@.%@f",format_avg,[defaults objectForKey:@"scoreformat"]],@"0.00"];
    }
    
    if([currentNumberTextField.text isEqualToString:@""] || [currentNumberTextField.text isEqualToString:defaultformatValue]){
        currentNumberTextField.text=defaultformatValue;
    }else{
        
        if([eventVOSelected.eventType isEqualToString:@"timed"]){
            currentNumberTextField.text= [NSString stringWithFormat:[NSString stringWithFormat:@"%@.%@f",format_avg,[defaults objectForKey:@"timeformat"]],[currentNumberTextField.text floatValue]];
            cvo.time=currentNumberTextField.text;
            [self updateScoreTimeInDB:[contestantsArray objectAtIndex:currentNumberTextField.tag-400]];
        }
        else{
            currentNumberTextField.text= [NSString stringWithFormat:[NSString stringWithFormat:@"%@.%@f",format_avg,[defaults objectForKey:@"scoreformat"]],[currentNumberTextField.text floatValue]];
            cvo.score=currentNumberTextField.text;
            [self updateScoreTimeInDB:[contestantsArray objectAtIndex:currentNumberTextField.tag-400]];
        }
        [self getContestantsList];
    }
    }
}

-(void)updateScoreTimeInDB:(ContestantVO*)cvo{
    sqlite3_stmt *statement;
    NSString *insertSQL;
    if([eventVOSelected.eventType isEqualToString:@"timed"])
        insertSQL= [NSString stringWithFormat:
                    @"update rounddetails set time=\"%@\" where round=\"%d\" and contestantid = %@",cvo.time,currentRound,cvo.contestantid];
    else
        insertSQL= [NSString stringWithFormat:
                    @"update rounddetails set score=\"%@\" where round=%d and contestantid = %@",cvo.score,currentRound,cvo.contestantid];
    
    NSLog(@"insertSQL = %@",insertSQL);
    const char *insert_stmt = [insertSQL UTF8String];
    sqlite3_prepare_v2(database, insert_stmt,
                       -1, &statement, NULL);
    
    if (sqlite3_step(statement) == SQLITE_DONE)
    {
        NSLog(@"event detail updated");
    }else{
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(database));
    }
}

-(void)updateContestantNameInDB:(ContestantVO*)cvo{
        sqlite3_stmt *statement;
        NSString *insertSQL;
            insertSQL= [NSString stringWithFormat:
                        @"update contestants set contestantname=\"%@\" where contestantid = %@",cvo.contestantname,cvo.contestantid];
        
        NSLog(@"insertSQL = %@",insertSQL);
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,
                           -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"event detail updated");
        }else{
            NSLog(@"Error %s while preparing statement", sqlite3_errmsg(database));
        }
}

-(IBAction)doneButtonAction{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    isLandscape=NO;
    appDelegate.isLandscapeOK=YES;
}

-(void)viewDidLayoutSubviews{
    if(self.view.frame.size.width == ([[UIScreen mainScreen] bounds].size.width*([[UIScreen mainScreen] bounds].size.width<[[UIScreen mainScreen] bounds].size.height))+([[UIScreen mainScreen] bounds].size.height*([[UIScreen mainScreen] bounds].size.width>[[UIScreen mainScreen] bounds].size.height))){
        [self clearCurrentView];

        isLandscape=NO;
        [self.view addSubview:mainPortraitView];
        tblview.frame=CGRectMake(0, 75, self.view.bounds.size.width, self.view.bounds.size.height);
        bgimageview_portrait.frame=CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [self getContestantsList];
    }
    else{
        [self clearCurrentView];
        isLandscape=YES;
        tblview_landscape.frame=CGRectMake(0, 75, self.view.bounds.size.width, self.view.bounds.size.height-80);
        bgimageview_landscape.frame=CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [self.view addSubview:mainLandscapeView];
        [self getContestantsList];
    }
}

-(void)viewDidDisappear:(BOOL)animated{

}

- (void) clearCurrentView
{
    if (mainLandscapeView.superview)
    {
        [mainLandscapeView removeFromSuperview];
    }
    else if (mainPortraitView.superview)
    {
        [mainPortraitView removeFromSuperview];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    contStr=[[NSString alloc]init];
    contStr=textField.text;
    ContestantVO *cvo;
    if(currentTextFieldTag!=-1){
        if(currentTextFieldTag>=400)
        {
            cvo=[contestantsArray objectAtIndex:currentTextFieldTag-400];
            if(![currentNumberTextField.text isEqualToString:@""]){
                if([eventVOSelected.eventType isEqualToString:@"timed"])
                    cvo.time=currentNumberTextField.text;
                else
                    cvo.score=currentNumberTextField.text;
            }
        }else{
            cvo=[contestantsArray objectAtIndex:currentTextFieldTag-100];
            if(![currentNumberTextField.text isEqualToString:@""]){
                cvo.contestantname=currentNumberTextField.text;
            }
        }
        [self updateContestantNameInDB:cvo];
        [self updateScoreTimeInDB:cvo];
    }
    if(textField.tag>=400){
        currentTextFieldTag=textField.tag;
    }
    else{
        currentTextFieldTag=textField.tag;
    }
    currentNumberTextField=textField;
    textField.text=@"";
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    
    int movementDistance = 0;
     if(textField.tag>=420){
         if(isLandscape)
        movementDistance=(-(3*((textField.tag+1)-400))); // tweak as needed
         else
             movementDistance=(-(5*((textField.tag+1)-400)));
    }else if(textField.tag>=410){
        movementDistance=(-(10*((textField.tag+1)-400))); // tweak as needed
    }else if(textField.tag>=400){
         movementDistance=(-(20*((textField.tag+1)-400)));
    }
    
    else if(textField.tag>=20){
        if(isLandscape)
            movementDistance=(-(3*((textField.tag+1)-100))); // tweak as needed
        else
        movementDistance=(-(5*((textField.tag+1)-100))); // tweak as needed
    }else if(textField.tag>=10){
        movementDistance=(-(10*((textField.tag+1)-100))); // tweak as needed
    }else{
        movementDistance=(-(20*((textField.tag+1)-100)));
    }
    const float movementDuration = 0.3f; // tweak as needed
    int movement = (up ? movementDistance : -movementDistance);
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

-(void)sortByContestantName{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"contestantname"
                                                 ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [contestantsArray sortedArrayUsingDescriptors:sortDescriptors];
    contestantsArray=[[NSMutableArray alloc] initWithArray:sortedArray];
    if(isLandscape){
        [self.tblview_landscape reloadData];
    }
    else{
        [self.tblview reloadData];
    }
}

-(NSMutableArray*)sortScoredAvgFunction:(NSMutableArray*)contArray{
    [contArray sortUsingComparator:
     ^NSComparisonResult(ContestantVO *obj1, ContestantVO *obj2){
         if(([obj2.avg floatValue]-[obj1.avg floatValue])>0)
             return 1;
         else if(([obj2.avg floatValue]-[obj1.avg floatValue])<0)
             return -1;
         else
             return 0;
     }];
    return contArray;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    sorttype=[[NSString alloc] init];
	if([title isEqualToString:@"Place in Round"]){
        if([eventVOSelected.eventType isEqualToString:@"scored"]){
            roundLabel.text=@"Place\nRound";
            roundLabel_Landscape.text=@"Place\nRound";
            sorttype=@"Score";
            contestantsArray=[[NSMutableArray alloc] initWithArray:[self sortScoredEvent:contestantsArray]];
        }
        if([eventVOSelected.eventType isEqualToString:@"timed"]){
            roundLabel.text=@"Place\nRound";
            roundLabel_Landscape.text=@"Place\nRound";
            sorttype=@"Time";
            contestantsArray=[[NSMutableArray alloc] initWithArray:[self sortTimeArrayList:contestantsArray]];
        }
    }else if([title isEqualToString:@"Contestant Name"]){
        roundLabel.text=@"Sort\nName";
        roundLabel_Landscape.text=@"Sort\nName";
        sorttype=@"Contestant Name";
        [self sortByContestantName];
    }else if([title isEqualToString:@"Place in Average"]){
            sorttype=@"Average";
            roundLabel.text=@"Place\nAverage";
        roundLabel_Landscape.text=@"Place\nAverage";
        if([eventVOSelected.eventType isEqualToString:@"scored"]){
            contestantsArray = [[NSMutableArray alloc] initWithArray:[self sortScoredAvgFunction:contestantsArray]];
        }
        if([eventVOSelected.eventType isEqualToString:@"timed"]){
            contestantsArray = [[NSMutableArray alloc] initWithArray:[self sortTimeArrayList_Avg:contestantsArray]];
        }
    }
    
     if(isLandscape){
         [self.tblview_landscape reloadData];
     }
     else{
         [self.tblview reloadData];
     }
    
}


-(NSString*)getScoreTime:(NSString*)contName{
    NSMutableArray *tempArray=[[NSMutableArray alloc] initWithArray:contestantsArray];
    if([eventVOSelected.eventType isEqualToString:@"timed"]){
        if([sorttype isEqualToString:@"Avg"]){
            tempArray=[self sortTimeArrayList_Avg:tempArray];
        }else if([sorttype isEqualToString:@"Time"] || [sorttype isEqualToString:@"Contestant Name"]){
            tempArray=[[NSMutableArray alloc] initWithArray:tempArray];
        }
    }else{
        if([sorttype isEqualToString:@"Avg"]){
            tempArray=[self sortScoredAvgFunction:tempArray];
        }else if([sorttype isEqualToString:@"Score"] || [sorttype isEqualToString:@"Contestant Name"]){
            tempArray=[[NSMutableArray alloc] initWithArray:tempArray];
        }
    }
    for(int count=0;count<[tempArray count];count++){
        ContestantVO *cvo=[tempArray objectAtIndex:count];
        if([cvo.contestantname isEqualToString:contName]){
            if([eventVOSelected.eventType isEqualToString:@"timed"])
                return cvo.time;
            else
                return cvo.score;
        }
    }
    return @"";
}

-(int)getPosition:(ContestantVO*)cvo:(NSString*)contName{
    NSMutableArray *tempArray=[[NSMutableArray alloc] initWithArray:contestantsArray];
    if([eventVOSelected.eventType isEqualToString:@"timed"]){
        if([sorttype isEqualToString:@"Average"])
            tempArray=[self sortTimeArrayList_Avg:tempArray];
        else
            tempArray=[self sortTimeArrayList:tempArray];
    }else{
        if([sorttype isEqualToString:@"Average"])
            tempArray=[self sortScoredAvgFunction:tempArray];
        else
            tempArray=[self sortScoredEvent:tempArray];
    }
    
    for (int count=0; count<[tempArray count]; count++) {
        ContestantVO *cvo=[tempArray objectAtIndex:count];
        if([cvo.contestantname isEqualToString:contName]){
            return count+1;
        }
    }
    
    return 0;
}

-(double)getRoundPredictions:(ContestantVO*)cont:(int)contNumber{
    double roundscore=0;
    NSMutableArray *tempArray=[[NSMutableArray alloc] initWithArray:contestantsArray];
    
    if([eventVOSelected.eventType isEqualToString:@"timed"]){
        tempArray=[self sortTimeArrayList:tempArray];
        ContestantVO *firstcontestant=[tempArray objectAtIndex:contNumber];
        if([firstcontestant.time isEqualToString:cont.time])
            return 0;
        else{
            roundscore=[firstcontestant.time doubleValue]-[cont.time doubleValue];
            if(roundscore<0)
                return 0;
        }
    }else{
        tempArray=[self sortScoredEvent:tempArray];
        ContestantVO *firstcontestant=[tempArray objectAtIndex:contNumber];
        if([firstcontestant.score isEqualToString:cont.score])
            return 0;
        else{
            roundscore=[firstcontestant.score doubleValue]-[cont.score doubleValue];
            if(roundscore<0)
                return 0;
        }
    }
    
    return roundscore;
}


-(double)getAvgPredictions:(ContestantVO*)cont:(int)contNumber{
    double roundscore=0;
    NSMutableArray *tempArray=[[NSMutableArray alloc] initWithArray:contestantsArray];
    
    if([eventVOSelected.eventType isEqualToString:@"timed"]){
        tempArray=[self sortTimeArrayList_Avg:tempArray];
        ContestantVO *firstcontestant=[tempArray objectAtIndex:contNumber];
        if([firstcontestant.avg isEqualToString:cont.avg])
            return 0;
        else{
            roundscore=[firstcontestant.avg doubleValue]-[cont.avg doubleValue];
            if(roundscore<0)
                return 0;
        }
    }else{
        tempArray=[self sortScoredAvgFunction:tempArray];
        ContestantVO *firstcontestant=[tempArray objectAtIndex:contNumber];
        if([firstcontestant.avg isEqualToString:cont.avg])
            return 0;
        else{
            roundscore=[firstcontestant.avg doubleValue]-[cont.avg doubleValue];
            if(roundscore<0)
                return 0;
        }
    }
    
    return roundscore;
}


-(IBAction)sortFunction{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"My Rodeo" message:@"Please choose the sort parameter" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Contestant Name",@"Place in Round",@"Place in Average",nil];
    [alert show];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([textField.text isEqualToString:@""]){
       [self getContestantsList];
    }else{
        ContestantVO *contestant;
        if(textField.tag>=400)
             contestant=[contestantsArray objectAtIndex:textField.tag-400];
        else
            contestant=[contestantsArray objectAtIndex:textField.tag-100];
    if(textField.tag>=100 && textField.tag<200){
        contestant.contestantname=textField.text;
    }
    [self updateContestantNameInDB:contestant];
        [self getContestantsList];
    }
    
              if([textField.text isEqualToString:@""]){
                  textField.text=contStr;
            }
    

    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma tableview delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [contestantsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    NSString *format_avg=@"%";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        cell.backgroundColor=[UIColor clearColor];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ContestantVO *contestant=[contestantsArray objectAtIndex:indexPath.row];
    usernameTextField=[[UITextField alloc] init];
    roundTextField=[[UITextField alloc] init];
    avgTextField=[[UITextField alloc] init];
    timeTextField=[[UITextField alloc] init];

    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if(isLandscape){
            //usernameTextField=[[UITextField alloc] initWithFrame:CGRectMake(5, 5, 90, 30)];
            usernameTextField.frame=CGRectMake(5, 5, 90, 30);
            usernameTextField.font = [UIFont systemFontOfSize:12];

        }
        else{
            //usernameTextField=[[UITextField alloc] initWithFrame:CGRectMake(5, 5,130, 30)];
            usernameTextField.font = [UIFont systemFontOfSize:14];

            usernameTextField.frame=CGRectMake(5, 5,130, 30);

        }
    }
    else{
        if(isLandscape){
            usernameTextField.font = [UIFont systemFontOfSize:20];
            usernameTextField=[[UITextField alloc] initWithFrame:CGRectMake(20, 5, 200, 60)];
        }else{
            usernameTextField.font = [UIFont systemFontOfSize:30];
            usernameTextField=[[UITextField alloc] initWithFrame:CGRectMake(20, 5, 300, 60)];
        }
    }
    usernameTextField.text=contestant.contestantname;
    usernameTextField.tag=100+indexPath.row;
    usernameTextField.textAlignment=NSTextAlignmentCenter;
    usernameTextField.textColor=[UIColor blackColor];
    usernameTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellbg.png"]];
    usernameTextField.delegate=self;
    usernameTextField.tintColor=[UIColor blueColor];
    [cell.contentView addSubview:usernameTextField];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if(isLandscape)
             roundTextField.frame=CGRectMake(100, 5, 30, 30);
        else
             roundTextField.frame=CGRectMake(140, 5, 30, 30);
    }
    else if(isLandscape)
        roundTextField=[[UITextField alloc] initWithFrame:CGRectMake(240, 5, 50, 60)];
    else
        roundTextField=[[UITextField alloc] initWithFrame:CGRectMake(340, 5, 70, 60)];
    roundTextField.enabled=FALSE;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        roundTextField.font = [UIFont fontWithName:@"Segoe Print" size:12];
    else{
        if(!isLandscape)
            roundTextField.font = [UIFont fontWithName:@"Segoe Print" size:30];
    }
    
    roundTextField.tag=200+indexPath.row;
    roundTextField.tintColor=[UIColor blueColor];
    roundTextField.text=[NSString stringWithFormat:@"%d",[self getPosition:contestant :contestant.contestantname]];
    roundTextField.textColor=[UIColor redColor];
    roundTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_shorimg.png"]];
    roundTextField.textAlignment = NSTextAlignmentCenter;
    roundTextField.keyboardType=UIKeyboardTypeNumberPad;
    roundTextField.delegate=self;
    [cell.contentView addSubview:roundTextField];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if(isLandscape){
            avgTextField.frame=CGRectMake(135, 5, 55, 30);
        avgTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellcontentsbg_short.png"]];
        }
        else{
            avgTextField.frame=CGRectMake(180, 5, 55, 30);
        avgTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellcontentsbg_short.png"]];
        }
    }
    
    else  if(isLandscape){
        avgTextField=[[UITextField alloc] initWithFrame:CGRectMake(300, 5, 100, 60)];
    avgTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_shorimg.png"]];
    }
    else{
        avgTextField=[[UITextField alloc] initWithFrame:CGRectMake(420, 5, 150, 60)];
    avgTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_shorimg.png"]];
    }
    avgTextField.tintColor=[UIColor blueColor];

    if([eventVOSelected.eventType isEqualToString:@"scored"])
        if(![contestant.avg isEqualToString:@"0"]){
            avgTextField.text=contestant.avg;
        }
        else{
            avgTextField.text=@"0";
        }
    
    if([eventVOSelected.eventType isEqualToString:@"timed"])
        if(![contestant.avg isEqualToString:@"0.00"]){
            avgTextField.text=contestant.avg;
        }
        else{
            avgTextField.text=@"0.00";
        }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        avgTextField.font = [UIFont fontWithName:@"Segoe Print" size:12];
    else{
        if(!isLandscape)
        avgTextField.font = [UIFont fontWithName:@"Segoe Print" size:30];
    }
    avgTextField.tag=300+indexPath.row;
    avgTextField.textAlignment = NSTextAlignmentCenter;
    avgTextField.enabled=FALSE;
    avgTextField.textColor=[UIColor redColor];
    avgTextField.delegate=self;

    [cell.contentView addSubview:avgTextField];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if(isLandscape){
            timeTextField.frame=CGRectMake(205, 5, 55, 30);
        timeTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellcontentsbg_short.png"]];
        }
        else{
            timeTextField.frame=CGRectMake(250, 5, 55, 30);
        timeTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellcontentsbg_short.png"]];
        }
    }
    else if(isLandscape){
        timeTextField=[[UITextField alloc] initWithFrame:CGRectMake(410, 5, 100, 60)];
    timeTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_shorimg.png"]];
    }
    else{
        timeTextField=[[UITextField alloc] initWithFrame:CGRectMake(590, 5, 150, 60)];
    timeTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_shorimg.png"]];
    }
   
    timeTextField.tintColor=[UIColor blueColor];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        timeTextField.font = [UIFont fontWithName:@"Segoe Print" size:12];
    else{
        if(!isLandscape)
            timeTextField.font = [UIFont fontWithName:@"Segoe Print" size:30];
    }
    timeTextField.tag=400+indexPath.row;
    timeTextField.text=[self getScoreTime:contestant.contestantname];
    timeTextField.keyboardType=UIKeyboardTypeDecimalPad;
    timeTextField.textAlignment = NSTextAlignmentCenter;
    timeTextField.textColor=[UIColor redColor];
    timeTextField.delegate=self;
    [timeTextField setInputAccessoryView:numberToolbar];
    [cell.contentView addSubview:timeTextField];
    
    if(isLandscape){
        firstinroundTextField=[[UITextField alloc] init];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            firstinroundTextField.frame=CGRectMake(285, 5, 55, 30);
        firstinroundTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellcontentsbg_short.png"]];
        }
        else{
            firstinroundTextField.frame=CGRectMake(520, 5, 100, 60);
        firstinroundTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_shorimg.png"]];
        }
        
        if([eventVOSelected.eventType isEqualToString:@"timed"]){
            if([contestant.time doubleValue]==0)
                firstinroundTextField.text=[NSString stringWithFormat:[NSString stringWithFormat:@"%@.%@f",format_avg,[defaults objectForKey:@"timeformat"]],[self getRoundPredictions:contestant :0]];
            else
                firstinroundTextField.text=@"--";
        }
        else{
            if([contestant.score doubleValue]==0)
                firstinroundTextField.text=[NSString stringWithFormat:[NSString stringWithFormat:@"%@.%@f",format_avg,[defaults objectForKey:@"scoreformat"]],[self getRoundPredictions:contestant :0]];
            else
                firstinroundTextField.text=@"--";
        }
        firstinroundTextField.keyboardType=UIKeyboardTypeNumberPad;
        firstinroundTextField.font = [UIFont fontWithName:@"Segoe Print" size:12];
        firstinroundTextField.tag=600+indexPath.row;
        firstinroundTextField.textAlignment = NSTextAlignmentCenter;
        firstinroundTextField.textColor=[UIColor redColor];
        firstinroundTextField.tintColor=[UIColor blueColor];
        firstinroundTextField.delegate=self;
        [cell.contentView addSubview:firstinroundTextField];
        lastplaceinroundTextField=[[UITextField alloc] init];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            lastplaceinroundTextField.frame=CGRectMake(350, 5, 55, 30);
        lastplaceinroundTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellcontentsbg_short.png"]];
            }
        else{
            lastplaceinroundTextField.frame=CGRectMake(630, 5, 100,60);
        lastplaceinroundTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_shorimg.png"]];
        }
        if([eventVOSelected.eventType isEqualToString:@"timed"]){
            if([contestant.time doubleValue]==0)
                lastplaceinroundTextField.text=[NSString stringWithFormat:[NSString stringWithFormat:@"%@.%@f",format_avg,[defaults objectForKey:@"timeformat"]],[self getRoundPredictions:contestant :([eventVOSelected.places intValue]-1)]];
            else
                lastplaceinroundTextField.text=@"--";
        }
        else{
            if([contestant.score doubleValue]==0)
                lastplaceinroundTextField.text=[NSString stringWithFormat:[NSString stringWithFormat:@"%@.%@f",format_avg,[defaults objectForKey:@"scoreformat"]],[self getRoundPredictions:contestant :([eventVOSelected.places intValue]-1)]];
            else
                lastplaceinroundTextField.text=@"--";
        }
        lastplaceinroundTextField.keyboardType=UIKeyboardTypeNumberPad;
        lastplaceinroundTextField.font = [UIFont fontWithName:@"Segoe Print" size:12];
        lastplaceinroundTextField.tag=700+indexPath.row;
        lastplaceinroundTextField.textAlignment = NSTextAlignmentCenter;
        lastplaceinroundTextField.textColor=[UIColor redColor];
        lastplaceinroundTextField.delegate=self;
        [cell.contentView addSubview:lastplaceinroundTextField];
        firstinavgTextField=[[UITextField alloc] init];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            firstinavgTextField.frame=CGRectMake(420, 5, 55, 30);
        firstinavgTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellcontentsbg_short.png"]];
        }
        else{
            firstinavgTextField.frame=CGRectMake(740, 5, 100, 60);
        firstinavgTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_shorimg.png"]];
        }
        if([eventVOSelected.eventType isEqualToString:@"timed"]){
            if([contestant.time doubleValue]==0)
                firstinavgTextField.text=[NSString stringWithFormat:[NSString stringWithFormat:@"%@.%@f",format_avg,[defaults objectForKey:@"timeformat"]],[self getAvgPredictions:contestant :0]];
            else
                firstinavgTextField.text=@"--";
        }
        else{
            if([contestant.score doubleValue]==0)
                firstinavgTextField.text=[NSString stringWithFormat:[NSString stringWithFormat:@"%@.%@f",format_avg,[defaults objectForKey:@"scoreformat"]],[self getAvgPredictions:contestant :0]];
            else
                firstinavgTextField.text=@"--";
        }
        firstinavgTextField.keyboardType=UIKeyboardTypeNumberPad;
        firstinavgTextField.font = [UIFont fontWithName:@"Segoe Print" size:12];
        firstinavgTextField.tag=800+indexPath.row;
        firstinavgTextField.textAlignment = NSTextAlignmentCenter;
        firstinavgTextField.textColor=[UIColor redColor];
        firstinroundTextField.delegate=self;
        [cell.contentView addSubview:firstinavgTextField];
        lastplaceinavgTextField=[[UITextField alloc] init];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            lastplaceinavgTextField.frame=CGRectMake(490, 5, 55, 30);
        lastplaceinavgTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellcontentsbg_short.png"]];
        }
        else{
            lastplaceinavgTextField.frame=CGRectMake(850, 5, 100, 60);
        lastplaceinavgTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_shorimg.png"]];
        }
        
        if([eventVOSelected.eventType isEqualToString:@"timed"]){
            if([contestant.time doubleValue]==0)
                lastplaceinavgTextField.text=[NSString stringWithFormat:[NSString stringWithFormat:@"%@.%@f",format_avg,[defaults objectForKey:@"timeformat"]],[self getAvgPredictions:contestant :([eventVOSelected.places intValue]-1)]];
            else
                lastplaceinavgTextField.text=@"--";
        }
        else{
            if([contestant.score doubleValue]==0)
                lastplaceinavgTextField.text=[NSString stringWithFormat:[NSString stringWithFormat:@"%@.%@f",format_avg,[defaults objectForKey:@"scoreformat"]],[self getAvgPredictions:contestant :([eventVOSelected.places intValue]-1)]];
            else
                lastplaceinavgTextField.text=@"--";
        }
        
        lastplaceinavgTextField.keyboardType=UIKeyboardTypeNumberPad;
        lastplaceinavgTextField.font = [UIFont fontWithName:@"Segoe Print" size:12];
        lastplaceinavgTextField.tag=900+indexPath.row;
        lastplaceinavgTextField.textAlignment = NSTextAlignmentCenter;
        lastplaceinavgTextField.textColor=[UIColor redColor];
        lastplaceinavgTextField.delegate=self;
        [cell.contentView addSubview:lastplaceinavgTextField];
    }
    
    roundTextField.enabled = false;
    avgTextField.enabled = false;
    totaltimeTextField.enabled = false;
    firstinroundTextField.enabled = false;
    lastplaceinroundTextField.enabled = false;
    firstinavgTextField.enabled = false;
    lastplaceinavgTextField.enabled = false;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return 40;
    else
        return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

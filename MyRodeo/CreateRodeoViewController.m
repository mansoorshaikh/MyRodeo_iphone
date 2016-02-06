//
//  CreateRodeoViewController.m
//  MyRodeo
//
//  Created by mansoor shaikh on 24/12/13.
//  Copyright (c) 2013 ClientsSolution. All rights reserved.
//

#define kOFFSET_FOR_KEYBOARD 150.0


#import "CreateRodeoViewController.h"
#import "EventsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PickLocationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import "Rodeo.h"
#import "EventVO.h"
#import "EventsLookUpViewController.h"
@interface CreateRodeoViewController ()
@property(nonatomic) double oldlat;
@property(nonatomic) double oldlong;

@end

@implementation CreateRodeoViewController
@synthesize oldlat,oldlong,RodeoDB,rodeoList,viewUp;
@synthesize datepicker,toolbar,appDelegate,activityIndicator,locationManager;
@synthesize eventsbtn,startrodeobtn,saverodeobtn,bgimage,noofplacesTextField;
@synthesize nameTextField,locationTextField,noofroundsTextFields,rodeodateTextField;
@synthesize rodeonameLabel,rodeoAddressLabel,rodeoDateLabel,rodeo_noofrounds_Label;

- (void) animateTextView:(BOOL) up
{
    const int movementDistance =90; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    int movement= movement = (up ? -movementDistance : movementDistance);
    NSLog(@"%d",movement);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

-(NSString*)getDestPath
{
    NSString* srcPath = [[NSBundle mainBundle]pathForResource:@"Rodeo" ofType:@"sqlite"];
    NSArray* arrayPathComp = [NSArray arrayWithObjects:NSHomeDirectory(),@"Documents",@"Rodeo.sqlite", nil];
    
    NSString* destPath = [NSString pathWithComponents:arrayPathComp];
    NSLog(@"src path:%@",srcPath);
    NSLog(@"dest path:%@",destPath);
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

-(IBAction)startRodeo{
   [self InsertRecords:@"yes"];
    
}

-(IBAction)saveRodeo{
    [self InsertRecords:@"no"];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
}


-(IBAction)saveRodeo__{
    [NSThread detachNewThreadSelector:@selector(threadStartAnimating:) toTarget:self withObject:nil];
    
    NSString *post =[NSString stringWithFormat:@"rodeoname=%@&location=%@&rodeostartdate=%@&numberofrounds=%@&isstarted=no",[nameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"_"],[locationTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"_"],[rodeodateTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"_"],noofroundsTextFields.text];
    
    NSString *urlString = [[NSString alloc]initWithFormat:@"http://www.mobiwebcode.com/rodeo/addrodeo.php?%@",post];
    
    NSLog(@"register url %@",urlString);
    
    NSData *mydata = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:urlString]];
    
    NSString *content = [[NSString alloc]  initWithBytes:[mydata bytes]
                                                  length:[mydata length] encoding: NSUTF8StringEncoding];
    if([content isEqualToString:@"success"]){
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"OSC" message:@"Rodeo saved successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        int myInt = [prefs integerForKey:@"rodeocount"];
        myInt=myInt+1;
        [prefs setInteger:myInt forKey:@"rodeocount"];
    }
    [activityIndicator stopAnimating];
}

- (void) threadStartAnimating:(id)data {
    [activityIndicator startAnimating];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSUInteger)supportedInterfaceOrientations
{
    appDelegate.isLandscapeOK=NO;
    return UIInterfaceOrientationMaskPortrait;
}

-(IBAction)doneButtonPressed{
    viewUp=NO;
    [self animateTextView:NO];
    NSDateFormatter *f2 = [[NSDateFormatter alloc] init];
    [f2 setDateFormat:@"LLLL dd, YYYY"];
    NSString *s = [f2 stringFromDate:datepicker.date];
    rodeodateTextField.text=[[NSString alloc]initWithFormat:@"%@",s];
    toolbar.hidden=YES;
    datepicker.hidden=YES;
}

-(IBAction)eventsButtonClicked{
    appDelegate.isfromLookup=NO;
    EventsViewController *evc;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        evc=[[EventsViewController alloc] initWithNibName:@"EventsViewController" bundle:nil];
    else
        evc=[[EventsViewController alloc] initWithNibName:@"EventsViewController_iPad" bundle:nil];
    [self.navigationController pushViewController:evc animated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    viewUp=NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(textField!=nameTextField){
        if([nameTextField.text isEqualToString:@""]){
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            int myInt = [prefs integerForKey:@"rodeocount"];
            nameTextField.text=[NSString stringWithFormat:@"Rodeo %d",myInt];
        }
    }
    
    if(textField==rodeodateTextField){
        
        toolbar.hidden=NO;
        datepicker.hidden=NO;
        [rodeodateTextField resignFirstResponder];
        [nameTextField resignFirstResponder];
        [noofroundsTextFields resignFirstResponder];
        return NO;
    }else if(textField==locationTextField){
        PickLocationViewController *picklocation;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            picklocation=[[PickLocationViewController alloc] initWithNibName:@"PickLocationViewController" bundle:nil];
        else
            picklocation=[[PickLocationViewController alloc] initWithNibName:@"PickLocationViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:picklocation animated:YES];
        datepicker.hidden=YES;
        toolbar.hidden=YES;
        return NO;
    }else if(textField==nameTextField){
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        int myInt = [prefs integerForKey:@"rodeocount"];
        if([nameTextField.text isEqualToString:[NSString stringWithFormat:@"Rodeo %d",myInt]])
        nameTextField.text=@"";
        [noofroundsTextFields resignFirstResponder];
        datepicker.hidden=YES;
        toolbar.hidden=YES;
    }else if(textField==noofroundsTextFields){
        if(viewUp==YES){
            viewUp=NO;
            [self animateTextView:NO];
        }
        
        if(viewUp==NO){
            viewUp=YES;
            [self animateTextView:YES];
        }
        [nameTextField resignFirstResponder];
        [noofplacesTextField resignFirstResponder];
        datepicker.hidden=YES;
        toolbar.hidden=YES;
    }else if(textField==noofplacesTextField){
        if(viewUp==YES){
            viewUp=NO;
            [self animateTextView:NO];
        }
        
        if(viewUp==NO){
            viewUp=YES;
            [self animateTextView:YES];
        }
        [nameTextField resignFirstResponder];
        [noofroundsTextFields resignFirstResponder];
        datepicker.hidden=YES;
        toolbar.hidden=YES;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField==nameTextField){
        if([nameTextField.text isEqualToString:@""]){
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            int myInt = [prefs integerForKey:@"rodeocount"];
            nameTextField.text=[NSString stringWithFormat:@"Rodeo %d",myInt];
        }
    }
    if(viewUp==YES){
        viewUp=NO;
        [self animateTextView:NO];
    }
    [textField resignFirstResponder];
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    appDelegate.isLandscapeOK=NO;
    if(![appDelegate.currentlocation isEqualToString:@""] && appDelegate.currentlocation!=nil){
        locationTextField.text=appDelegate.currentlocation;
    }
}

-(void)popviewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *newLocation=[locations lastObject];
    oldlat=newLocation.coordinate.latitude;
    oldlong=newLocation.coordinate.longitude;
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:oldlat longitude:oldlong] completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks) {
            NSString *locality = [placemark name];
            NSLog(@"locality %@",locality);
            if([placemark locality]!=nil)
                appDelegate.currentlocation=[NSString stringWithFormat:@"%@,%@,%@",[placemark locality],[placemark name],[placemark country]];
            else
                appDelegate.currentlocation=[NSString stringWithFormat:@"%@,%@",[placemark name],[placemark country]];
            
            locationTextField.text=appDelegate.currentlocation;
            NSLog(@"appDelegate.currentlocation = %@",appDelegate.currentlocation);
            [locationManager stopUpdatingLocation];
        }
        
    }];
}

-(void)InsertRecords:(NSString*)isstarted{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"noofcontestants %@",[defaults objectForKey:@"noofcontestants"]);
    int noofcontestants_default=[[defaults objectForKey:@"noofcontestants"] intValue];
    if([nameTextField.text isEqualToString:@""] || [locationTextField.text isEqualToString:@""] || [rodeodateTextField.text isEqualToString:@""] || [noofroundsTextFields.text isEqualToString:@""]){
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"My Rodeo"
                                                          message:@"Please enter the valid details to proceed."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }else if([appDelegate.eventsList count]==0){
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"My Rodeo"
                                                          message:@"Please add at least one event to proceed."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
    else{
    sqlite3_stmt *statement;
    NSLog(@"[self getDestPath] = %@",[self getDestPath]);
    
    if (sqlite3_open([[self getDestPath] UTF8String], &RodeoDB) == SQLITE_OK)
    {
        NSString *insertSQL;
        insertSQL = [NSString stringWithFormat:
                     @"insert into rodeodetails (rodeoname,location,rodeostartdate,numberofrounds) VALUES (\"%@\",\"%@\",\"%@\",\"%@\")",nameTextField.text,locationTextField.text,rodeodateTextField.text,noofroundsTextFields.text];
        
        NSLog(@"insertSQL = %@",insertSQL);
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(RodeoDB, insert_stmt,
                           -1, &statement, NULL);
        NSNumber *menuID;
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"record inserted");
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            menuID = [NSDecimalNumber numberWithLongLong:sqlite3_last_insert_rowid(RodeoDB)];
            int myInt = [prefs integerForKey:@"rodeocount"];
            myInt=myInt+1;
            [prefs setInteger:myInt forKey:@"rodeocount"];
        }else{
            NSLog(@"record insertion failed");
            NSLog(@"Error %s while preparing statement", sqlite3_errmsg(RodeoDB));
        }
        sqlite3_finalize(statement);
        sqlite3_close(RodeoDB);
        appDelegate.currentRodeo=[[Rodeo alloc] init];
        appDelegate.currentRodeo.rodeoid=[NSString stringWithFormat:@"%@",menuID];
        appDelegate.currentRodeo.rodeoname=nameTextField.text;
        appDelegate.currentRodeo.rodeostartdate=rodeodateTextField.text;
        appDelegate.currentRodeo.numberofrounds=noofroundsTextFields.text;
        appDelegate.isSaved=@"yes";
    }
        NSNumber *lastId = 0;
        for (int i=0; i<[appDelegate.eventsList count]; i++) {
            EventVO *eventvo=[appDelegate.eventsList objectAtIndex:i];
            sqlite3_stmt *statement;
            NSLog(@"[self getDestPath] = %@",[self getDestPath]);
            
            if (sqlite3_open([[self getDestPath] UTF8String], &RodeoDB) == SQLITE_OK)
            {
                NSString *insertSQL;
                insertSQL = [NSString stringWithFormat:
                             @"insert into events (rodeoid,eventname,contestants,places,currentround,eventType) VALUES (%@,\"%@\",\"%@\",\"%@\",1,\"%@\")",appDelegate.currentRodeo.rodeoid,eventvo.eventname,eventvo.contestants,eventvo.places,eventvo.eventType];
                
                NSLog(@"insertSQL = %@",insertSQL);
                const char *insert_stmt = [insertSQL UTF8String];
                sqlite3_prepare_v2(RodeoDB, insert_stmt,
                                   -1, &statement, NULL);
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    NSLog(@"record inserted");
                    lastId = [NSDecimalNumber numberWithLongLong:sqlite3_last_insert_rowid(RodeoDB)];
                }else{
                    NSLog(@"record insertion failed");
                    NSLog(@"Error %s while preparing statement", sqlite3_errmsg(RodeoDB));
                }
                sqlite3_finalize(statement);
                sqlite3_close(RodeoDB);
            }
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"My Rodeo"
                                                        message:@"Rodeo created successfully."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

        if([isstarted isEqualToString:@"yes"]){
            EventsLookUpViewController *evc;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                evc=[[EventsLookUpViewController alloc] initWithNibName:@"EventsLookUpViewController" bundle:nil];
            else
                evc=[[EventsLookUpViewController alloc] initWithNibName:@"EventsLookUpViewController_ipad" bundle:nil];
            evc.rodeoid_=appDelegate.currentRodeo.rodeoid;
            
            evc.selectedRodeo=[[Rodeo alloc] init];
            evc.selectedRodeo=appDelegate.currentRodeo;
            
            
            [self.navigationController pushViewController:evc animated:YES];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
  }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate=[[UIApplication sharedApplication] delegate];
    rodeoList=[[NSMutableArray alloc] init];
    appDelegate.eventsList=[[NSMutableArray alloc] init];
    locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
	locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
    
    NSDate *now = [[NSDate alloc] init];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"LLLL dd, YYYY"];
    NSString *theDate = [dateFormat stringFromDate:now];
    rodeodateTextField.text=theDate;
    
    [activityIndicator stopAnimating];
    datepicker.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellbg.png"]];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    bgimage.frame=CGRectMake(0, 0, width, height);

    if(height==568){
        self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"innerbg.png"]];
        bgimage.image=[UIImage imageNamed:@"innerbg_.png"];
    }else{
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        bgimage.image=[UIImage imageNamed:@"innerbg_.png"];
        self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"innerbg.png"]];
        eventsbtn.frame=CGRectMake(40, 305, 260, 40);
        datepicker.frame=CGRectMake(0, 315, 320, 162);
        }
     }
    
    nameTextField.layer.borderColor=[[UIColor blackColor]CGColor];
    locationTextField.layer.borderColor=[[UIColor blackColor]CGColor];
    noofroundsTextFields.layer.borderColor=[[UIColor blackColor]CGColor];
    noofplacesTextField.layer.borderColor=[[UIColor blackColor]CGColor];
    rodeodateTextField.layer.borderColor=[[UIColor blackColor]CGColor];
    
    nameTextField.layer.borderWidth = 0.5f;
    locationTextField.layer.borderWidth = 0.5f;
    noofroundsTextFields.layer.borderWidth = 0.5f;
    noofplacesTextField.layer.borderWidth = 0.5f;
    rodeodateTextField.layer.borderWidth = 0.5f;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    noofroundsTextFields.text=[defaults objectForKey:@"numberofrounds"];
    noofplacesTextField.text=[defaults objectForKey:@"noofplacespaid"];

    //add left bar button
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        eventsbtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:18];
        startrodeobtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:18];
        saverodeobtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:18];
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Segoe Print" size:24] forKey:NSFontAttributeName];
    }else{
        eventsbtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:45];
        startrodeobtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:45];
        saverodeobtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:45];
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Segoe Print" size:40] forKey:NSFontAttributeName];
    }
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar.png"]];
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.title=@"Create a Rodeo";
    toolbar.hidden=YES;

    datepicker.hidden=YES;
    datepicker.backgroundColor = [UIColor whiteColor];
    
    [nameTextField.layer setCornerRadius:8.0f];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int myInt = [prefs integerForKey:@"rodeocount"];
    if(myInt==0){
        nameTextField.text=[NSString stringWithFormat:@"Rodeo 1"];
        myInt=myInt+1;
        [prefs setInteger:myInt forKey:@"rodeocount"];
    }
    else
    nameTextField.text=[NSString stringWithFormat:@"Rodeo %d",myInt];
    [locationTextField.layer setCornerRadius:8.0f];
    [noofroundsTextFields.layer setCornerRadius:8.0f];
    [noofplacesTextField.layer setCornerRadius:8.0f];
    [rodeodateTextField.layer setCornerRadius:8.0f];
    
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    noofroundsTextFields.inputAccessoryView = numberToolbar;
    noofplacesTextField.inputAccessoryView = numberToolbar;
}

-(void)cancelNumberPad{
    [noofroundsTextFields resignFirstResponder];
    [self animateTextView:NO];
}

-(void)doneWithNumberPad{
    viewUp=NO;
    [self animateTextView:NO];
    NSString *numberFromTheKeyboard = noofroundsTextFields.text;
    [noofroundsTextFields resignFirstResponder];
    [noofplacesTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  PickLocationViewController.m
//  MyRodeo
//
//  Created by mansoor shaikh on 01/01/14.
//  Copyright (c) 2014 ClientsSolution. All rights reserved.
//

#import "PickLocationViewController.h"

@interface PickLocationViewController ()

@end

@implementation PickLocationViewController
@synthesize mapView,locationManager,currentLocation,annotation,appDelegate;
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

-(void)viewWillAppear:(BOOL)animated{
    appDelegate.isLandscapeOK=NO;
}

-(void)popviewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    [manager stopUpdatingLocation];
    locationManager.delegate = nil;
    locationManager = nil;
    
    CLLocationCoordinate2D currentLocations = newLocation.coordinate;
    MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(currentLocations, 100000, 100000);
    [mapView setRegion:region];
    
    self.annotation = [[MKPointAnnotation alloc] init];
    [self.annotation setCoordinate:currentLocations];
    [self.annotation setTitle:@"Current Location"];
    
    [self.mapView addAnnotation:annotation];
    
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:currentLocations.latitude longitude:currentLocations.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks) {
            NSString *locality = [placemark name];
            NSLog(@"locality %@",locality);
            if([placemark locality]!=nil)
                appDelegate.currentlocation=[NSString stringWithFormat:@"%@,%@,%@",[placemark locality],[placemark name],[placemark country]];
            else
                appDelegate.currentlocation=[NSString stringWithFormat:@"%@,%@",[placemark name],[placemark country]];
        }
        [self.mapView removeAnnotation:self.annotation];
        [self.annotation setTitle:appDelegate.currentlocation];
        [self.mapView addAnnotation:self.annotation];
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([self.annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *reuseId = @"pin";
    MKPinAnnotationView *pav = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (pav == nil)
    {
        pav = [[MKPinAnnotationView alloc] initWithAnnotation:self.annotation reuseIdentifier:reuseId];
        pav.draggable = YES; // Right here baby!
        pav.canShowCallout = YES;
    }
    else
    {
        pav.annotation = self.annotation;
    }
    return pav;
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding) // you can check out some more states by looking at the docs
    {
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        NSLog(@"dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
        
        CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:droppedAt.latitude longitude:droppedAt.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
            for (CLPlacemark * placemark in placemarks) {
                NSString *locality = [placemark name];
                NSLog(@"locality %@",locality);
                if([placemark locality]!=nil)
                    appDelegate.currentlocation=[NSString stringWithFormat:@"%@,%@,%@",[placemark locality],[placemark name],[placemark country]];
                else
                    appDelegate.currentlocation=[NSString stringWithFormat:@"%@,%@",[placemark name],[placemark country]];
            }
            [self.mapView removeAnnotation:self.annotation];
            [self.annotation setTitle:appDelegate.currentlocation];
            [self.mapView addAnnotation:self.annotation];
        }];
    }
}

-(void)donepicklocation{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden=NO;
    
    UIImage* image3 = [UIImage imageNamed:@"donebtn.png"];
    CGRect frameimg;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        frameimg= CGRectMake(0, 0, 50, 30);
    else
        frameimg= CGRectMake(0, 0, 80, 48);
    
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(donepicklocation)
         forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *anotherButton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.navigationItem.rightBarButtonItem=anotherButton;
    
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
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Segoe Print" size:24] forKey:NSFontAttributeName];
    }else{
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Segoe Print" size:40] forKey:NSFontAttributeName];
    }
    appDelegate=[[UIApplication sharedApplication] delegate];
    mapView.delegate=self;
    self.navigationItem.title=@"Pick Location";
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate =self;
    [locationManager startUpdatingLocation];
    
    UILongPressGestureRecognizer* lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.5;
    lpgr.delegate = self;
}

- (void) handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CLLocationCoordinate2D coordinate = [mapView convertPoint:[gestureRecognizer locationInView:mapView] toCoordinateFromView:mapView];
        [mapView setCenterCoordinate:coordinate animated:YES];
   }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

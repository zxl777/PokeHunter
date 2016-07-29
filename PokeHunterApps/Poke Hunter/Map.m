//
//  Map.m
//  Poke Hunter
//
//  Created by sky on 16/7/28.
//  Copyright © 2016年 iToyToy Limited. All rights reserved.
//

#import "Map.h"

@interface Map ()

@end

@implementation Map

- (void)viewDidLoad
{
    [super viewDidLoad];
    pins = [NSMutableArray array];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    self.Map.showsCompass = YES; // 是否显示指南针
    self.Map.showsScale = YES; // 是否显示比例尺
    self.Map.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    
    CLLocationCoordinate2D center =  CLLocationCoordinate2DMake(34.0522342,-118.2436849);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    
    [self.Map setRegion:region animated:YES];

    
    imgname =@"scan";
    flag = YES;
    
    BasicMapAnnotation *annotation=[[BasicMapAnnotation alloc] initWithLatitude:34.0522342 andLongitude:-118.2436849 tag:0];
    
    [pins addObject:annotation];
    
    annotation.title = @"Hello";
    [self.Map addAnnotation:annotation];
    
    
    
    NSTimer *TestingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(TickUdpPing) userInfo:nil repeats:YES];
}

-(void)TickUdpPing
{
    [self.Map removeAnnotations:pins];
    if (flag)
    imgname =@"scan";
    else
    imgname = @"help";
    
    flag=!flag;
    
    [self.Map addAnnotations:pins];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // create a proper annotation view, be lazy and don't use the reuse identifier
    MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:@"identifier"];
    
    // create a disclosure button for map kit
    UIButton *disclosure = [UIButton buttonWithType:UIButtonTypeContactAdd];
    
    [disclosure addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(disclosureTapped)]];
    view.rightCalloutAccessoryView = disclosure;
    
    view.enabled = YES;
    view.image = [UIImage imageNamed:imgname];
    
    view.canShowCallout = YES;
    
    return view;
}


- (IBAction)TapedScan:(id)sender
{
    [self.Map removeAnnotations:pins];
}


//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
//
//{
//    static NSString *pinID = @"pinID";
//    MKAnnotationView *customPinView = [mapView dequeueReusableAnnotationViewWithIdentifier:pinID];
//    if (!customPinView) {
//        customPinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinID];
//    }
//    
//    // 设置大头针图片
//    customPinView.image = [UIImage imageNamed:@"scan"];
//    
//    // 设置大头针可以弹出标注
//    customPinView.canShowCallout = YES;
//    
//    // 设置标注左侧视图
//    UIImageView *leftIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//    leftIV.image = [UIImage imageNamed:@"scan"];
//    customPinView.leftCalloutAccessoryView = leftIV;
//    
//    // 设置标注右侧视图
//    UIImageView *rightIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//    rightIV.image = [UIImage imageNamed:@"scan"];
//    customPinView.rightCalloutAccessoryView = rightIV;
//    
//    // 设置标注详情视图（iOS9.0）
//    customPinView.detailCalloutAccessoryView = [[UISwitch alloc] init];
//    
//    return customPinView;
//}

@end

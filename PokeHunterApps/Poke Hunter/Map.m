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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end

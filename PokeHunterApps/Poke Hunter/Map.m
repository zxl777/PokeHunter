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
    pokes = [NSMutableArray array];
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    self.Map.showsCompass = YES; // 是否显示指南针
    self.Map.showsScale = YES; // 是否显示比例尺
    self.Map.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    
    [self.Map setShowsUserLocation:NO]; //控制显示用户位置
    
    CLLocationCoordinate2D center =  CLLocationCoordinate2DMake(34.0522342,-118.2436849);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    
    [self.Map setRegion:region animated:YES];

    [self GetPokes];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D loc = [userLocation coordinate];
    //放大地图到自身的经纬度位置。
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 250, 250);
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(loc, span);
    
    [self.Map setRegion:region animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [PinsTimer invalidate];
    PinsTimer = nil;
}

-(void)AddPins
{
    [pins removeAllObjects];
    int tag=0;
    for (NSArray *poke in pokes)
    {
        float lat=[(poke[1][1]) floatValue];
        float lon=[(poke[1][0]) floatValue];
        
        BasicMapAnnotation *annotation=[[BasicMapAnnotation alloc] initWithLatitude:lat  andLongitude:lon tag:tag++];
        annotation.title = @"Hello";
        [pins addObject:annotation];
        
//        [self.Map addAnnotation:annotation];
    }
    
    [self.Map addAnnotations:pins];
}


-(void)GetPokes
{
    [SVProgressHUD show];
    
    [[APIClient api] GET:@"v1/pokes?longitude=-118.247&latitude=34.047&m=1000"
              parameters:nil
                progress:^(NSProgress * _Nonnull downloadProgress) {}
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         if (responseObject==nil)
             return;
         
         
         [SVProgressHUD dismiss];
         
         [pokes removeAllObjects];
         [pokes addObjectsFromArray:responseObject];
         NSLog(@"pokes=%@",pokes);
         
         [self AddPins];
         
         [self StartRefreshPins];
         
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"Error: %@", error);
         [SVProgressHUD dismiss];
     }];
}

-(void)StartRefreshPins
{
    PinsTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(TickUpdatePins) userInfo:nil repeats:YES];
}

-(void)TickUdpPing
{
    BasicMapAnnotation *annotation=[[BasicMapAnnotation alloc] initWithLatitude:34.0522342 andLongitude:-118.2436849 tag:0];
    annotation.title = @"Hello";
    
    [self.Map addAnnotation:annotation];
    [self.Map removeAnnotations:pins];
    
    [pins removeAllObjects];
    [pins addObject:annotation];
}

-(void)TickUpdatePins
{
    NSArray *old = [NSArray arrayWithArray:pins];
    [self AddPins];
    [self.Map addAnnotations:pins];
    
    [self.Map removeAnnotations:old];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if([annotation class] == MKUserLocation.class)
        return nil;
    // create a proper annotation view, be lazy and don't use the reuse identifier
    MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:@"identifier"];
    
    // create a disclosure button for map kit
//    UIButton *disclosure = [UIButton buttonWithType:UIButtonTypeContactAdd];
    
//    [disclosure addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                             action:@selector(disclosureTapped)]];
//    view.rightCalloutAccessoryView = disclosure;
    
    
//    UILabel *DissTime = [[UILabel alloc] init];
//    DissTime.text = @"AM9:38";
    
    view.enabled = YES;
//    view.image = [UIImage imageNamed:imgname];
    
    view.image =  [self GetImg:annotation];
    
    view.canShowCallout = NO;
    
    return view;
}


- (IBAction)TapedScan:(id)sender
{
}



-(UIImage *)GetImg:(id<MKAnnotation>)annotation
{
//    //获取系统当前时间
//    NSDate *currentDate = [NSDate date];
//    //用于格式化NSDate对象
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    //设置格式：zzz表示时区
////    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
//    [dateFormatter setDateFormat:@"mm:ss"];
//    //NSDate转NSString
//    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
    
    
    
    NSArray *poke = pokes[((BasicMapAnnotation *)annotation).tag];
    NSString *line = poke[0];
    NSArray *infos =  [line componentsSeparatedByString:@":"];

    //统一用秒做单位，不用毫秒。
    long long now = [[NSDate date] timeIntervalSince1970];
    long long hidetime = [infos[1] longLongValue];
    
    
    int livesecond = (int)(hidetime-now);
    
    if (livesecond<0)
    {
        livesecond =-1;
        return nil;
    }
    
    self.TimeShow.text = [NSString stringWithFormat:@"%02d:%02d",(livesecond/60),livesecond%60];
    
    NSString *EnableColorPokemon = [[APIClient api] getRemoteStr:@"EnableColorPokemon" defaultStr:@"NO"];
    
    EnableColorPokemon = @"YES";
    
    if ([EnableColorPokemon isEqualToString:@"NO"])
        self.PokeShow.image = [UIImage imageNamed:infos[0]];
    else
        self.PokeShow.image = [UIImage imageNamed:[infos[0] stringByAppendingString:@"_Color"]];
    
    UIGraphicsBeginImageContextWithOptions(self.PinView.frame.size, NO, 0);
    [self.PinView.layer renderInContext: UIGraphicsGetCurrentContext()];
    UIImage *TakeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        UIImageWriteToSavedPhotosAlbum(TakeImage, nil, nil, nil);
//    });
    
    
    return TakeImage;
    
}




//将时间戳转换为NSDate类型
-(NSDate *)getDateTimeFromMilliSeconds:(long long) miliSeconds
{
    NSTimeInterval tempMilli = miliSeconds;
    NSTimeInterval seconds = tempMilli/1000.0;//这里的.0一定要加上，不然除下来的数据会被截断导致时间不一致
//    NSLog(@"传入的时间戳=%f",seconds);
    return [NSDate dateWithTimeIntervalSince1970:seconds];
}

//将NSDate类型的时间转换为时间戳,从1970/1/1开始
-(long long)getDateTimeTOMilliSeconds:(NSDate *)datetime
{
    NSTimeInterval interval = [datetime timeIntervalSince1970];
//    NSLog(@"转换的时间戳=%f",interval);
    long long totalMilliseconds = interval*1000 ;
//    NSLog(@"totalMilliseconds=%llu",totalMilliseconds);
    return totalMilliseconds;
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    [PinsTimer invalidate];
    PinsTimer = nil;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)aView
{
    [self StartRefreshPins];
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

//
//  Map.h
//  Poke Hunter
//
//  Created by sky on 16/7/28.
//  Copyright © 2016年 iToyToy Limited. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Map : UIViewController
{
    NSMutableArray *pins;
    bool flag;
    NSString *imgname;
    NSTimer *PinsTimer;
    NSMutableArray *pokes;
}

@property (weak, nonatomic) IBOutlet MKMapView *Map;

@property (weak, nonatomic) IBOutlet UIView *PinView;
@property (weak, nonatomic) IBOutlet UILabel *TimeShow;

@end

//
//  Scan.m
//  Poke Hunter
//
//  Created by sky on 16/7/29.
//  Copyright © 2016年 iToyToy Limited. All rights reserved.
//

#import "Scan.h"

@interface Scan ()

@end

@implementation Scan

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.ScanTips.text = [[APIClient api] getRemoteStr:@"ScanTips" defaultStr:self.ScanTips.text];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [SVProgressHUD dismiss];
}

- (IBAction)TapedScan:(id)sender
{
    [SVProgressHUD showWithStatus:@"Scanning..."];
    
    [APIClient api].ScanWhere = (int)self.ScanWhere.selectedSegmentIndex;
    
    [self.navigationController popViewControllerAnimated:NO];
}

@end

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

- (IBAction)TapedScan:(id)sender
{
    [SVProgressHUD showWithStatus:@"Checking..."];
    
    
//    [[APIClient api] POST:@"/v1/addscanjob"
//               parameters:@{
//                            @"address":self.address.text,
//                            @"port":self.port.text,
//                            @"mail":self.mail.text
//                            }
//                 progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
//     {
//         NSLog(@"%@ %@", task, responseObject);
//         [SVProgressHUD showInfoWithStatus:responseObject [@"message"]];
//         if ([responseObject[@"succeed"] intValue] == 1)
//             [self.navigationController popViewControllerAnimated:YES];
//         [APIClient GA:@"成功提交了一个服务器"];
//     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
//     {
//         NSLog(@"Error: %@", error);
//     }];
}

@end

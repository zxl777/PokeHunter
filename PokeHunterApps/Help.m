//
//  Help.m
//  Poke Hunter
//
//  Created by sky on 16/7/29.
//  Copyright © 2016年 iToyToy Limited. All rights reserved.
//

#import "Help.h"

@interface Help ()

@end

@implementation Help

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *Url = [NSString stringWithFormat:@"http://minecraft-pe-servers.itoytoy.com/poke-hunter-help"];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[Url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
//    self.Web.scrollView.scrollEnabled = NO;
    self.Web.delegate = self;
    self.Web.scrollView.bounces = NO;
    [self.Web loadRequest:request];
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.Web.delegate = nil;
    [self.Web stopLoading];
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD show];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD dismiss];
}

@end

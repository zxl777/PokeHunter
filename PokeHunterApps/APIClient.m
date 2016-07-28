#import "APIClient.h"
#import "SVProgressHUD.h"
#import <SSKeychain/SSKeychain.h>


//static NSString * const APIBaseURLString = @"http://192.168.1.183:3000/";
static NSString * const APIBaseURLString = @"http://play.itoytoy.com:3000/";

@implementation APIClient

+ (instancetype)api {
    static APIClient *_api = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _api = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:APIBaseURLString]];
//        _api.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
        _api.token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
        _api.Userid = [[NSUserDefaults standardUserDefaults] objectForKey:@"Userid"];
        _api.Username = [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"];
        
        _api.CheckinDates = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"CheckinDates"]];

        
        _api.VotedDates = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"VotedDates"]];

        
        if (_api.token.length>0)
        {
            [_api setAccessToken:_api.token];
        }
        _api.BaseUrl = APIBaseURLString;

    });
    
    return _api;
}

-(void)Save
{
    [[NSUserDefaults standardUserDefaults] setObject:self.CheckinDates forKey:@"CheckinDates"];
    [[NSUserDefaults standardUserDefaults] setObject:self.VotedDates forKey:@"VotedDates"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)setUsername:(NSString *)username andPassword:(NSString *)password
{
    [self.requestSerializer clearAuthorizationHeader];
    [self.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
}


-(void)setJson
{
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    
    self.requestSerializer  = [AFJSONRequestSerializer serializer];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
}


-(void)setAccessToken:(NSString *)accessToken
{
    self.token = accessToken;
    [self.requestSerializer setValue:[@"Bearer " stringByAppendingString:accessToken] forHTTPHeaderField:@"Authorization"];
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)SaveUserid
{
    [[NSUserDefaults standardUserDefaults] setObject:self.Userid forKey:@"Userid"];
    [[NSUserDefaults standardUserDefaults] setObject:self.Username forKey:@"Username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


-(void)Logout
{
    [self setAccessToken:@""];
    self.Username = @"";
    self.Userid = @"";
    [self SaveUserid];
    
    [self.requestSerializer clearAuthorizationHeader];
}


//调通的上传函数，AFNetworking2.6.3 直接用api可能有bug，会出现超时错误。可能是没有将认证信息发出。

-(void)upload:(NSString *)filename
{
    //NSURL *filePathURL = [NSURL fileURLWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"goldengate@2x.png"]];
    
    NSURL *filePathURL = [NSURL fileURLWithPath:filename];
    
    
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST"
                                                                                              URLString: [APIBaseURLString stringByAppendingPathComponent:@"/upload/done"]
//                                    [NSString stringWithFormat:@"%@upload/done" ,APIBaseURLString]
                                                                                             parameters:@{@"access_token":self.token}
                                                                              constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                                    {
                                        NSString *ext = [[filename pathExtension] uppercaseString];
                                        if ([ext isEqualToString:@"GIF"])
                                        {
                                            [formData appendPartWithFileURL:filePathURL
                                                                       name:@"emoji"
                                                                   fileName:@"filename.gif"
                                                                   mimeType:@"image/gif"
                                                                      error:nil];
                                        }
                                        else if ([ext isEqualToString:@"PNG"])
                                        {
                                            [formData appendPartWithFileURL:filePathURL
                                                                       name:@"emoji"
                                                                   fileName:@"filename.png"
                                                                   mimeType:@"image/png"
                                                                      error:nil];

                                        }
                                        else
                                        {
                                            [formData appendPartWithFileURL:filePathURL
                                                                       name:@"emoji"
                                                                   fileName:@"filename.jpg"
                                                                   mimeType:@"image/jpg"
                                                                      error:nil];
                                            
                                        }

                                        
                                    } error:nil];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:nil
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error)
                      {
                          NSLog(@"Error: %@", error);
                      } else
                      {
                          NSLog(@"%@ %@", response, responseObject);
//                          [SVProgressHUD dismiss];
                      }
                  }];
    
    [uploadTask resume];
}


+(void)download:(NSString *)url
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
    }];
    [downloadTask resume];
}


//-(void)Login2GetToken
//{
//    [self POST:@"/auth/local"
//    parameters:@{@"identifier":@"sky@itoytoy.com",@"password":@"zxlzxlzxl"}
//       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject)
//    {
//        NSLog(@"%@ %@", task, responseObject);
//        self.token = responseObject[@"token"];
//        [self setAccessToken:self.token];
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"Error: %@", error);
//    }];
//}

#pragma mark 投票部分

-(NSString *)getUniqueDeviceIdentifierAsString
{
    
    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    
    NSString *strApplicationUUID = [SSKeychain passwordForService:appName account:@"incoding"];
    if (strApplicationUUID == nil)
    {
        strApplicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SSKeychain setPassword:strApplicationUUID forService:appName account:@"incoding"];
    }
    
    return strApplicationUUID;
}

-(void)SetUserUUID
{
    self.UserUUID = [self getUniqueDeviceIdentifierAsString];
    CocoaSecurityResult *md5 = [CocoaSecurity md5:self.UserUUID];
    self.UserMD5 = md5.hexLower;
}

-(void)Checkin
{
    [self POST:@"/v1/checkin" parameters:@{@"userid":self.UserUUID} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        NSLog(@"%@ %@", task, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        NSLog(@"Error: %@", error);
    }];
}


-(void)Vote:(NSString *)serverid
{
    [self POST:@"/v1/vote" parameters:@{@"qq":self.UserMD5,@"serverid":serverid} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@ %@", task, responseObject);
        
        [self AddVotedDate];
        
        [SVProgressHUD showInfoWithStatus:responseObject[@"message"]];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
    }];
}

-(BOOL)isLogined
{
    NSString * token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    return (token.length>0);
}

+(void)InitPushNotification
{
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil]];
    }
}

+(void)PushNotification:(NSString *)message delay:(int)delay
{
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil]];
    }
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];//初始化本地通知
    if (localNotification != nil) {
        NSDate *now = [NSDate new];
        localNotification.fireDate = [now dateByAddingTimeInterval:delay];//15秒后通知
//        localNotification.repeatInterval = NSCalendarUnitMinute;//循环次数，NSCalendarUnitMinute一分一次
        localNotification.timeZone = [NSTimeZone defaultTimeZone];//UILocalNotification激发时间是否根据时区改变而改变
        localNotification.applicationIconBadgeNumber =0;//应用的红色数字
        //        localNotification.soundName = UILocalNotificationDefaultSoundName;//声音，可以换成自己的，如：alarm.soundName = @"myMusic.caf"
        localNotification.alertBody = message;//提示信息 弹出提示框
        localNotification.alertAction = @"打开";//解锁按钮文字，就是在锁屏情况下有一个‘滑动来XXX’,这儿的XXX就是这里所设置的alertAction。如果不设置就是@“查看”
        localNotification.hasAction = YES;//是否显示额外的按钮，为no时alertAction的设置不起作用，hasAction默认是YES
        //通知的额外信息，不会展示出来，是用来判断通知是哪一条的额外信息
        NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"xiaofei" forKey:@"birthday"];
        localNotification.userInfo = infoDict;//添加额外的信息
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];//添加本地通知到推送队列中
    }
}

+(void)RemvoeAllNotification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    return;
}

+ (int)convertToInt:(NSString*)strtemp//判断中英混合的的字符串长度
{
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUTF8StringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUTF8StringEncoding] ;i++)
    {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
        
    }
    return strlength;
}


+ (NSData *)wifiAddress
{
    // On iPhone, WiFi is always "en0"
    
    NSData *result = nil;
    
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    
    if ((getifaddrs(&addrs) == 0))
    {
        cursor = addrs;
        while (cursor != NULL)
        {
//            NSLog(@"cursor->ifa_name = %s", cursor->ifa_name);
            
            if (strcmp(cursor->ifa_name, "en0") == 0)
            {
                if (cursor->ifa_addr->sa_family == AF_INET)
                {
                    struct sockaddr_in *addr = (struct sockaddr_in *)cursor->ifa_addr;
//                    NSLog(@"cursor->ifa_addr = %s", inet_ntoa(addr->sin_addr));
                    
                    result = [NSData dataWithBytes:addr length:sizeof(struct sockaddr_in)];
                    cursor = NULL;
                }
                else
                {
                    cursor = cursor->ifa_next;
                }
            }
            else
            {
                cursor = cursor->ifa_next;
            }
        }
        freeifaddrs(addrs);
    }
    
    return result;
}


+ (NSData *)cellAddress
{
    // On iPhone, 3G is "pdp_ipX", where X is usually 0, but may possibly be 0-3 (i'm guessing...)
    
    NSData *result = nil;
    
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    
    if ((getifaddrs(&addrs) == 0))
    {
        cursor = addrs;
        while (cursor != NULL)
        {
//            NSLog(@"cursor->ifa_name = %s", cursor->ifa_name);
            
            if (strncmp(cursor->ifa_name, "pdp_ip", 6) == 0)
            {
                if (cursor->ifa_addr->sa_family == AF_INET)
                {
                    struct sockaddr_in *addr = (struct sockaddr_in *)cursor->ifa_addr;
//                    NSLog(@"cursor->ifa_addr = %s", inet_ntoa(addr->sin_addr));
                    
                    result = [NSData dataWithBytes:addr length:sizeof(struct sockaddr_in)];
                    cursor = NULL;
                }
                else
                {
                    cursor = cursor->ifa_next;
                }
            }
            else
            {
                cursor = cursor->ifa_next;
            }
        }
        freeifaddrs(addrs);
    }
    return result;
}







//storyBoard view自动适配

+ (void)StoryboardAutolayout:(UIView *)allView
{
    [APIClient api].autoSizeScaleX = [[UIScreen mainScreen] bounds].size.width/320;
    [APIClient api].autoSizeScaleY = [APIClient api].autoSizeScaleX;
    
    for (UIView *temp in allView.subviews)
    {
        if (temp.tag == 1) continue;
        
        temp.frame = CGRectMake1(temp.frame.origin.x, temp.frame.origin.y, temp.frame.size.width, temp.frame.size.height);
        for (UIView *temp1 in temp.subviews)
        {
            temp1.frame = CGRectMake1(temp1.frame.origin.x, temp1.frame.origin.y, temp1.frame.size.width, temp1.frame.size.height);
        }
    }
}

//修改CGRectMake
CG_INLINE CGRect
CGRectMake1(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
    CGRect rect;
    rect.origin.x = x * [APIClient api].autoSizeScaleX;
    rect.origin.y = y * [APIClient api].autoSizeScaleY;
    rect.size.width = width * [APIClient api].autoSizeScaleX;
    rect.size.height = height * [APIClient api].autoSizeScaleY;
    return rect;
}


-(void)CheckVipUser
{
    NSLog(@"OnlineTime = %d ,RunAppCount = %d",(int)[[NSUserDefaults standardUserDefaults] integerForKey:@"OnlineTime"],
          (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"RunAppCount"]);
    
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"OnlineTime"]>(5*60) ||[[NSUserDefaults standardUserDefaults] integerForKey:@"RunAppCount"]>10)
    {
        self.CustomerRetention =@"YES";
    }
    else
    {
        self.CustomerRetention =@"NO";
    }
    
    NSLog(@"[APIClient api].CustomerRetention = %@",[APIClient api].CustomerRetention);
}

-(void)SetBeginOnlineTime
{
    BeginOnlineTime = [ NSDate date];
}

-(void)SetEndOnlineTime
{
    NSTimeInterval onlineTime = [ [ NSDate date ] timeIntervalSinceDate:BeginOnlineTime];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"OnlineTime"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:onlineTime forKey:@"OnlineTime"];
    }
    else
    {
        int old = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"OnlineTime"];
        [[NSUserDefaults standardUserDefaults] setInteger:onlineTime+old forKey:@"OnlineTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)MeasureTimeStart
{
    BeginMeasureTime=[NSDate date];
}

-(NSNumber *)MeasureTimeEnd
{
    NSDate *endDate=[NSDate date];
    double Seconds= [endDate timeIntervalSinceDate:BeginMeasureTime];
    BeginMeasureTime=[NSDate date];
    return [NSNumber numberWithDouble:Seconds];
}

-(void)SaveRunAppCount
{
    int RunAppCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RunAppCount"] intValue];
    RunAppCount ++;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:RunAppCount] forKey:@"RunAppCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    NSLog(@"RunAppCount = %d", RunAppCount);
}

+(bool)isiPad
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}


- (void)initRemoteConfig
{
    self.remoteConfig = [FIRRemoteConfig remoteConfig];
}

- (void)fetchConfig
{
    long expirationDuration = 3600;
    
#ifdef DEBUG
    {
        NSLog(@"设置开发者模式，马上刷新远程参数的cache");
        FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] initWithDeveloperModeEnabled:YES];
        self.remoteConfig.configSettings = remoteConfigSettings;
        expirationDuration = 0;
    }
#endif
    
    [self.remoteConfig fetchWithExpirationDuration:expirationDuration completionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
        if (status == FIRRemoteConfigFetchStatusSuccess)
        {
            NSLog(@"成功获取网络参数");
            [self.remoteConfig activateFetched];
        }
        else
        {
            NSLog(@"Config not fetched");
            NSLog(@"Error %@", error.localizedDescription);
        }
    }];
}


-(NSString *)getRemoteStr:(NSString *)key defaultStr:(NSString *)defaultStr
{
    NSString *str = self.remoteConfig[key].stringValue;
    
    if ([str isEqualToString:@""])
        return defaultStr;
    else
    {
        str = [str stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        return str;
    }
}


-(void)AddCheckinDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    NSString *CheckinDate = [dateFormatter stringFromDate:[NSDate date]];

    if (self.CheckinDates[CheckinDate]==nil)
        self.CheckinDates[CheckinDate] = @1;
    else
        self.CheckinDates[CheckinDate] = @([self.CheckinDates[CheckinDate] intValue]+1);
    
    NSLog(@"self.CheckinDates = %@, Count=%lu",self.CheckinDates,(unsigned long)[self.CheckinDates allKeys].count);
    
    if ([self.CheckinDates allKeys].count >1)
        [APIClient GA:@"回头客"];
}


-(void)AddVotedDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    NSString *VotedDate = [dateFormatter stringFromDate:[NSDate date]];
    
    if (self.VotedDates[VotedDate]==nil)
        self.VotedDates[VotedDate] = @1;
    else
        self.VotedDates[VotedDate] = @([self.VotedDates[VotedDate] intValue]+1);
    
    NSLog(@"VotedDates = %@",self.VotedDates);
}


-(BOOL)isTodayVoted
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    NSString *VotedDate = [dateFormatter stringFromDate:[NSDate date]];

    if (self.VotedDates[VotedDate]==nil)
        return NO;
    else
        return YES;
}


+(void)GA:(NSString *)event
{
    [FIRAnalytics logEventWithName:event parameters:nil];
}

@end


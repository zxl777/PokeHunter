#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import <arpa/inet.h>
#import <net/if.h>
#import <ifaddrs.h>

@interface APIClient : AFHTTPSessionManager
{
    NSDate *BeginMeasureTime;
    NSDate *BeginOnlineTime;
}
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *Userid;
@property (strong, nonatomic) NSString *Username;
@property (strong, nonatomic) NSString *BaseUrl;

@property (nonatomic, readwrite) NSString *CustomerRetention;

@property (nonatomic, readwrite) int ScanWhere;

+ (instancetype)api;
-(void)upload:(NSString *)filename;
//-(void)Login2GetToken;
-(BOOL)isLogined;
+(void)download:(NSString *)url;
-(void)setAccessToken:(NSString *)accessToken;
-(void)Logout;
-(void)SaveUserid;


//全局变量和共享工具函数
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) NSString *port;
@property (strong, nonatomic) NSDictionary *server;


@property (nonatomic, strong) FIRRemoteConfig *remoteConfig;
@property (strong, nonatomic) NSString *Help;
- (void)initRemoteConfig;
-(NSString *)getRemoteStr:(NSString *)key defaultStr:(NSString *)defaultStr;

+(void)InitPushNotification;
+(void)PushNotification:(NSString *)message delay:(int)delay;
+(void)RemvoeAllNotification;

@property (nonatomic, readwrite) bool NotificationPushed;

+ (int)convertToInt:(NSString*)strtemp;
+ (NSData *)wifiAddress;
+ (NSData *)cellAddress;


@property (strong, nonatomic) NSString *UserUUID;
@property (strong, nonatomic) NSString *UserMD5;

-(void)SetUserUUID;
-(void)Vote:(NSString *)serverid;
-(void)Checkin;


@property (nonatomic, readwrite) float autoSizeScaleX;
@property (nonatomic, readwrite) float autoSizeScaleY;
+ (void)StoryboardAutolayout:(UIView *)allView;

-(void)MeasureTimeStart;

-(NSNumber *)MeasureTimeEnd;

-(void)SetBeginOnlineTime;
-(void)SetEndOnlineTime;
-(void)SaveRunAppCount;

-(void)CheckVipUser;
- (void)fetchConfig;

+(bool)isiPad;

-(void)AddCheckinDate;
@property (strong, nonatomic) NSMutableDictionary *CheckinDates;
@property (strong, nonatomic) NSMutableDictionary *VotedDates;
-(void)Save;

-(void)AddVotedDate;
-(BOOL)isTodayVoted;

+(void)GA:(NSString *)event;

@end

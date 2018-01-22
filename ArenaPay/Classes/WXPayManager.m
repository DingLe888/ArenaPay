//
//  WXPayManager.m
//  ArenaPay
//
//  Created by 丁乐 on 2017/10/26.
//

#import "WXPayManager.h"
//#import "WXAPI.h"
#import "WXAPI.h"

@interface WXPayManager()<WXApiDelegate>

@property (nonatomic,strong)NSDictionary *data;

@property (nonatomic,copy)NSString *authState;

@property (nonatomic,copy) void(^callBack)(NSDictionary *);

@end
@implementation WXPayManager

static WXPayManager *instance = nil;

+(instancetype)getInstance{
    @synchronized(self) {
        if (instance == nil) {
            instance = [[WXPayManager alloc]init];
        }
    }
    return instance;
}

+(void)setWXAppKey:(NSString *)key{
    [WXApi registerApp:key];
}

+(BOOL)applicationOpenUrl:(NSURL *)url{
    [WXApi handleOpenURL:url delegate:[self getInstance]];
    
    return YES;
}

+(void)wxpay:(NSDictionary *)data{
    
    [WXPayManager getInstance].data = data;
    if((NSDictionary *)[data objectForKey:@"payInfo"]){
        NSDictionary *dataDic = (NSDictionary *)[data objectForKey:@"payInfo"];
        [[WXPayManager getInstance] wxpay:dataDic];
    }
    
//    [[WXPayManager getInstance] wxpay:data];
}


// 发起支付
-(void)wxpay:(NSDictionary *)data{
    
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    if ([WXApi isWXAppInstalled] == NO){
        [resultDict setObject:@"failed" forKey:@"result"];
        [resultDict setObject:@{@"resultStatus":@"3000",@"result":@"failed",@"memo":@"未安装微信"} forKey:@"data"];
         [self sendNotifi:resultDict];
        return;
    }
    
    if (data == nil) {
        [resultDict setObject:@"failed" forKey:@"result"];
        [resultDict setObject:@{@"resultStatus":@"1000",@"result":@"failed",@"memo":@"参数为空"} forKey:@"data"];
         [self sendNotifi:resultDict];
        return;
    }
    
    //调起微信支付
    PayReq* req   = [[PayReq alloc] init];
    req.partnerId = [data objectForKey:@"partnerid"];
    req.prepayId  = [data objectForKey:@"prepayid"];
    req.nonceStr  = [data objectForKey:@"noncestr"];
    req.timeStamp = [[data objectForKey:@"timestamp"] intValue];
    req.package   = [data objectForKey:@"package"];
    req.sign      = [data objectForKey:@"sign"];
    
    if (req.partnerId == nil || req.prepayId == nil || req.nonceStr == nil || req.package == nil || req.sign == nil) {
        [resultDict setObject:@"failed" forKey:@"result"];
        [resultDict setObject:@{@"resultStatus":@"2000",@"result":@"failed",@"memo":@"参数错误"} forKey:@"data"];
         [self sendNotifi:resultDict];
        return;
    }
    
    //日志输出
    NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[data objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
    
    if([WXApi sendReq:req] == NO){
        [resultDict setObject:@"failed" forKey:@"result"];
        [resultDict setObject:@{@"resultStatus":@"5000",@"result":@"failed",@"memo":@"调起微信支付失败"} forKey:@"data"];
        
        [self sendNotifi:resultDict];
        return;
    }else{
        
    }
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        
        
        switch (resp.errCode) {
            case WXSuccess:
                [resultDict setObject:@"success" forKey:@"result"];
                [resultDict setObject:@{@"resultStatus":@"9000",@"result":@"success",@"memo":@"支付结果：成功！"} forKey:@"data"];
                [self sendNotifi:resultDict];
                break;
                
            default:
                [resultDict setObject:@"failed" forKey:@"result"];
                [resultDict setObject:@{@"resultStatus":@(resp.errCode),@"result":@"failed",@"memo":@"支付结果：失败！"} forKey:@"data"];
                [self sendNotifi:resultDict];
                break;
        }
        
    }else if ([resp isKindOfClass:[SendAuthResp class]]){
        
        SendAuthResp* authResp = (SendAuthResp*)resp;
        
        if (![authResp.state isEqualToString:self.authState]) {
            if(self.callBack){
                self.callBack(@{@"result":@"failed",@"data":@"授权失败！"});
            }
        }
        
        switch (resp.errCode) {
            case WXSuccess:
                NSLog(@"RESP:code:%@,state:%@\n", authResp.code, authResp.state);
                if(self.callBack){
                    self.callBack(@{@"result":@"success",@"data":@{@"code":authResp.code,@"state":authResp.state}});
                }
                break;
            case WXErrCodeAuthDeny:
                if(self.callBack){
                    self.callBack(@{@"result":@"failed",@"data":@"授权失败！"});
                }
                break;
            case WXErrCodeUserCancel:
                if(self.callBack){
                    self.callBack(@{@"result":@"failed",@"data":@"用户取消！"});
                }
            default:
                break;
        }
        
        
    }
    
}




-(void)sendNotifi:(NSDictionary *)result{
    if (self.data && self.data[@"callback"]) {
        NSString *notifiName = self.data[@"callback"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notifiName object:result userInfo:nil];
    }
}


//  =============   SSO   =============


/**
 发起SSO Block参数 {"result":"success","data":"数据，或者msg"}

 @param callBack 回调block
 */
+(void)sendAuthRequest:(void(^)(NSDictionary *))callBack{
    NSString *state = [self randomKey];
    
    [[self getInstance] sendAuthRequest:state callBack:callBack];
}

-(void)sendAuthRequest:(NSString *)state callBack:(void(^)(NSDictionary *))callBack{
    self.callBack = callBack;
    self.authState = state;
    //构造SendAuthReq结构体
    SendAuthReq* req =[[SendAuthReq alloc ] init ];
    req.scope = @"snsapi_userinfo" ;
    req.state = state ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    if([WXApi sendReq:req] == NO){
        if(callBack){
            callBack(@{@"result":@"failed",@"data":@"发情登录失败！"});
        }
    }
}

+ (NSString *)randomKey {
    /* Get Random UUID */
    NSString *UUIDString;
    CFUUIDRef UUIDRef = CFUUIDCreate(NULL);
    CFStringRef UUIDStringRef = CFUUIDCreateString(NULL, UUIDRef);
    UUIDString = (NSString *)CFBridgingRelease(UUIDStringRef);
    CFRelease(UUIDRef);
    /* Get Time */
    double time = CFAbsoluteTimeGetCurrent();
    /* MD5 With Sale */
    return [NSString stringWithFormat:@"%@%f", UUIDString, time];
}

@end

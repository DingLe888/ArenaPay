//
//  WXPayManager.m
//  ArenaPay
//
//  Created by 丁乐 on 2017/10/26.
//

#import "WXPayManager.h"
#import "WXAPI.h"

@interface WXPayManager()<WXApiDelegate>

@property (nonatomic,strong)NSDictionary *data;

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
        
    }
    
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


-(void)sendNotifi:(NSDictionary *)result{
    if (self.data && self.data[@"callback"]) {
        NSString *notifiName = self.data[@"callback"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notifiName object:result userInfo:nil];
    }
}


@end

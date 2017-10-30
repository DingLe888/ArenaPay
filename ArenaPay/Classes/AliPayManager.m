//
//  AliPayManager.m
//  ArenaPay
//
//  Created by 丁乐 on 2017/10/26.
//

#import "AliPayManager.h"
#import <AlipaySDK/AlipaySDK.h>

@interface AliPayManager()

@property (nonatomic,strong)NSDictionary *data;

@end
@implementation AliPayManager

static AliPayManager *instance = nil;

+(instancetype)getInstance{
    @synchronized(self) {
        if (instance == nil) {
            instance = [[AliPayManager alloc]init];
        }
    }
    return instance;
}

+(void)setAliAppKey:(NSString *)key{
//    [WXApi registerApp:key];
}

+(void)applicationOpenUrl:(NSURL *)url{
    
    if ([url.host isEqualToString:@"safepay"]) {

        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];

            [resultDict setObject:@"success" forKey:@"result"];
            [resultDict setDictionary:resultDic];
            [[AliPayManager getInstance] sendNotifi:resultDict];
            NSLog(@"result2 = %@",resultDic);
        }];
    }
}

+(void)alipay:(NSDictionary *)data{
    [[AliPayManager getInstance] alipay:data];
}

-(void)alipay:(NSDictionary *)data{
    
    self.data = data;
    
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    if (data == nil) {
        [resultDict setObject:@"failed" forKey:@"result"];
        [resultDict setObject:@"参数为空" forKey:@"msg"];
        [self sendNotifi:resultDict];
        
        return;
    }
    
    // 将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = [data objectForKey:@"payInfo"];
    
    NSString *appScheme = @"arenaAlipay";
    
    if (orderString == nil || appScheme == nil) {
        [resultDict setObject:@"failed" forKey:@"result"];
        [resultDict setObject:@"参数错误" forKey:@"msg"];
        [self sendNotifi:resultDict];
        return;
    }
    
    //日志输出
    
    [[AlipaySDK defaultService] payOrder:orderString
                              fromScheme:appScheme
                                callback:^(NSDictionary *resultDic) {
                                    NSLog(@"alipay reslut1 = %@",resultDic);
                                    NSString *resultStr = [(NSString *)resultDic[@"resultStatus"]  isEqual: @"9000"] ? @"success" : @"failed";
                                    
                                    [resultDict setObject:resultStr forKey:@"result"];// memo
                                    [resultDict setObject:resultDic[@"memo"] forKey:@"msg"];
                                    
                                    [resultDict setDictionary:resultDic];
                                    [self sendNotifi:resultDict];

                                }
     ];
}


-(void)sendNotifi:(NSDictionary *)result{
    if (self.data && self.data[@"callback"]) {
        NSString *notifiName = self.data[@"callback"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notifiName object:result userInfo:nil];
    }
}

@end

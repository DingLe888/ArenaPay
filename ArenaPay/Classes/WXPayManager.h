//
//  WXPayManager.h
//  ArenaPay
//
//  Created by 丁乐 on 2017/10/26.
//

#import <Foundation/Foundation.h>

@interface WXPayManager : NSObject

+(void)setWXAppKey:(NSString *)key;

+(BOOL)applicationOpenUrl:(NSURL *)url;

+(void)wxpay:(NSDictionary *)data;
@end

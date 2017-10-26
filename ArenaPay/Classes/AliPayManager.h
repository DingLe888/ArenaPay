//
//  AliPayManager.h
//  ArenaPay
//
//  Created by 丁乐 on 2017/10/26.
//

#import <Foundation/Foundation.h>

@interface AliPayManager : NSObject

+(void)setAliAppKey:(NSString *)key;

+(void)applicationOpenUrl:(NSURL *)url;

+(void)alipay:(NSDictionary *)data;
@end

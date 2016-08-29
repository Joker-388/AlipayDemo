//
//  ViewController.m
//  JKRAlipayDemo
//
//  Created by tronsis_ios on 16/8/24.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import "ViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "AFHTTPSessionManager.h"
#import "Order.h"
#import "DataSigner.h"

@interface ViewController ()

@end

@implementation ViewController

static NSString *appScheme = @"jokeralipay"; //设置url scheme

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    /**
    // 向服务器请求订单数据，支付宝需要的订单数据是一个字符串
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary]; //服务器获取订单需要传递的参数
    //假设这里需要传需要支付的订单ID，服务器接到后会根据这个ID向支付宝获取订单数据
    parameters[@"order_id"] = @"";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:@"服务器获取订单数据的URL" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //用服务器返回的订单信息发起支付
        [self jumpToAlipayWithOrder:responseObject[@"order"]]; 
    } failure:nil];
     */
    
    NSString *partner = @"2088XXXXXXXXXXXX";                   // 合作者身份(PID)
    NSString *seller = @"XXXXXX@xxxxxx.com";                   // 支付宝收款账号
    NSString *privateKey = @"XXXXXXXXXXXXXXXX";                // 商户方的私钥
    
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.sellerID = seller;
    order.outTradeNO = [self generateTradeNO];                  // 订单ID
    order.subject = @"1";                                       // 商品标题
    order.body = @"没有钱怎么办";                                 // 商品描述
    order.totalFee = @"0.01";                                   // 商品价格
    order.notifyURL = @"http://www.baidu.com";                  // 回调URL
    order.service = @"mobile.securitypay.pay";                  // 固定为mobile.securitypay.pay
    order.paymentType = @"1";                                   // 支付类型，1：商品购买
    order.inputCharset = @"utf-8";                              // 商户网站使用的编码格式，固定为utf-8
    order.itBPay = @"30m";                                      // 设置未付款交易的超时时间
    order.showURL = @"m.alipay.com";                            // 商品地址
    
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        [self jumpToAlipayWithOrder:orderString];
    }
}

#pragma mark - 根据订单参数调起支付宝客户端支付
- (void)jumpToAlipayWithOrder:(NSString *)order {
    [[AlipaySDK defaultService] payOrder:order fromScheme:appScheme callback:nil]; ///这个block完成了并没有回调
}

#pragma mark 生成随机订单号
- (NSString *)generateTradeNO {
    static int kNumber = 15;
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++) {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

@end

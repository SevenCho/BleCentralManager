//
//  XSPeripheral.h
//  BleCentralManager
//
//  Created by 曹雪松 on 2018/4/28.
//  Copyright © 2018 曹雪松. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CBPeripheral;

@interface XSPeripheral : NSObject

@property (nonatomic, copy) NSString *peripheralName;
@property (nonatomic, copy) NSString *peripheralIdentity;
@property (nonatomic, copy) NSString *peripheralRssi;
@property (nonatomic, copy) NSString *peripheralState;

@property (nonatomic, strong) CBPeripheral *peripheral;

@end

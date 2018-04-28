//
//  XSBleManager.h
//  KYRemoteUnit
//
//  Created by 曹雪松 on 2017/1/16.
//  Copyright © 2017年 曹雪松. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol XSBleManagerDelegate <NSObject>

@optional

/**
 蓝牙状态更新

 @param central 中心管理者
 */
- (void)xs_centralManagerDidUpdateState:(CBCentralManager *)central;

/**
 即将恢复蓝牙的状态信息

 @param central 中心管理者
 @param dict 蓝牙被终止时系统维护的一个关于蓝牙中心管理者状态信息的字典
 
 *  @discussion            For apps that opt-in to state preservation and restoration, this is the first method invoked when your app is relaunched into
 *                        the background to complete some Bluetooth-related task. Use this method to synchronize your app's state with the state of the
 *                        Bluetooth system.
 *
 *  @seealso            CBCentralManagerRestoredStatePeripheralsKey;
 *  @seealso            CBCentralManagerRestoredStateScanServicesKey;
 *  @seealso            CBCentralManagerRestoredStateScanOptionsKey;
 */
- (void)xs_centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict;

/**
 发现外设

 @param central 中心管理者
 @param peripheral 外设
 @param advertisementData 外设信息
 @param RSSI 信号
 */
- (void)xs_centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;

/**
 重连外设

 @param central 中心管理者
 @param peripherals 之前已经发现过的外设
 */
- (void)xs_centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals;

/**
 成功连接上外设

 @param central 中心管理者
 @param peripheral 连接上的外设
 */
- (void)xs_centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;

/**
 已经断开外设

 @param central 中心管理者
 @param peripheral 当前连接的外设
 @param error 错误信息
 */
- (void)xs_centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

/**
 连接外设失败

 @param central 中心管理者
 @param peripheral 当前连接的外设
 @param error 错误信息
 */
- (void)xs_centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

/**
 发现外设的服务

 @param peripheral 连接的外设
 @param error 错误信息
 */
- (void)xs_peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;

/**
 发现外设的特征值

 @param peripheral 连接的外设
 @param service 外设的服务
 @param error 错误信息
 */
- (void)xs_peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;

/**
 外设的特征值已经更新

 @param peripheral 连接的外设
 @param characteristic 特征值
 @param error 错误信息
 */
- (void)xs_peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

/**
 写入到指定的特征值数据成功

 @param peripheral 连接的外设
 @param characteristic 特征值
 @param error 错误信息
 */
- (void)xs_peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

/**
 订阅的特征通知数据已经更新

 @param peripheral 连接的外设
 @param characteristic 特征值
 @param error 错误信息
 */
- (void)xs_peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

@end

@interface XSBleManager : NSObject

@property (nonatomic, weak) id<XSBleManagerDelegate> delegate;

+ (XSBleManager *)manager;

/** 开始扫描 */
- (void)xs_startScan;

/** 停止扫描 */
- (void)xs_stopScan;

/** 连接外设 */
- (void)xs_connectPeripheral:(CBPeripheral *)peripheral;

/** 与外设断开连接 */
- (void)xs_disconnectPeripheral:(CBPeripheral *)peripheral;

/** 寻回外设 (传外设的UUID) */
- (NSArray<CBPeripheral *> *)xs_retrievePeripheralsWithIdentifiers:(NSArray<NSUUID *> *)identifiers;


@end

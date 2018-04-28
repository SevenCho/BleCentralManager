//
//  XSBleManager.m
//  KYRemoteUnit
//
//  Created by 曹雪松 on 2017/1/16.
//  Copyright © 2017年 曹雪松. All rights reserved.
//

#import "XSBleManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface XSBleManager () <CBCentralManagerDelegate, CBPeripheralDelegate> {
    struct {
        unsigned int didUpdateState : 1;
        unsigned int didDiscoverPeripheral  : 1;
        unsigned int didConnectPeripheral   : 1;
        unsigned int didDisconnectPeripheral    : 1;
        unsigned int didFailToConnectPeripheral : 1;
        unsigned int willRestoreState   : 1;
        unsigned int didRetrievePeripheral  : 1;
        unsigned int didDiscoverServices    : 1;
        unsigned int didDiscoverCharacteristicsForService   : 1;
        unsigned int didUpdateValueForCharacteristic    : 1;
        unsigned int didWriteValueForCharacteristic : 1;
        unsigned int didUpdateNotificationStateForCharacteristic    : 1;
    } _delegateFlags;
}


/**  中心设备管理者 */
@property (nonatomic, strong) CBCentralManager *centralManager;
/**  外设 */
@property (nonatomic, strong) CBPeripheral *peripheral;

/** 发现的外设数组 */
@property (nonatomic, strong) NSMutableArray *discoveredPeripherals;
/** 发现的外设服务数组 */
@property (nonatomic, strong) NSMutableArray *discoveredServices;

/** 是否自动连接 */
@property (nonatomic, assign) BOOL autoConnect;
/** 升级模式 */
@property (nonatomic, assign) BOOL upgradeMode;

@end

static NSString * const UUIDString = @"1F99C5AC-ED06-4973-AE41-33E158DF56B9"; /**< 设备UUID（含有指令写入的特征） */
static NSString * const ServiceUUIDString1 = @"0000FEE9-0000-1000-8000-00805F9B34FB"; /**< 设备服务UUID（含有指令写入的特征） */
static NSString * const ServiceUUIDString2 = @"0000FEE8-0000-1000-8000-00805F9B34FB"; /**< 设备服务UUID（含有OTA升级的特征）== 0xFEE8 */

@implementation XSBleManager

#pragma mark - 初始化
- (id)init
{
    if (self = [super init]) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _discoveredPeripherals = [[NSMutableArray alloc] init];
        _discoveredServices = [[NSMutableArray alloc] init];
        
        if (_autoConnect) {
            [self xs_startScan];
        }
    }
    return self;
}

- (void)dealloc
{
    [self xs_stopScan];
    _centralManager.delegate = nil;
    _peripheral.delegate = nil;
}

+ (XSBleManager *)manager
{
    static XSBleManager *_sharedInstance = nil;
    if (_sharedInstance == nil) {
        XSLogFunc
        _sharedInstance = [[XSBleManager alloc] init];
    }
    return _sharedInstance;
}

- (void)setDelegate:(id<XSBleManagerDelegate>)delegate
{
    _delegate = delegate;
    
    _delegateFlags.didUpdateState = [_delegate respondsToSelector:@selector(xs_centralManagerDidUpdateState:)];
    _delegateFlags.didDiscoverPeripheral = [_delegate respondsToSelector:@selector(xs_centralManager:didDiscoverPeripheral:advertisementData:RSSI:)];
    _delegateFlags.didConnectPeripheral = [_delegate respondsToSelector:@selector(xs_centralManager:didConnectPeripheral:)];
    _delegateFlags.didDisconnectPeripheral = [_delegate respondsToSelector:@selector(xs_centralManager:didDisconnectPeripheral:error:)];
    _delegateFlags.didFailToConnectPeripheral = [_delegate respondsToSelector:@selector(xs_centralManager:didFailToConnectPeripheral:error:)];
    _delegateFlags.willRestoreState = [_delegate respondsToSelector:@selector(xs_centralManager:willRestoreState:)];
    _delegateFlags.didRetrievePeripheral = [_delegate respondsToSelector:@selector(xs_retrievePeripheralsWithIdentifiers:)];
    _delegateFlags.didDiscoverServices = [_delegate respondsToSelector:@selector(xs_peripheral:didDiscoverServices:)];
    _delegateFlags.didDiscoverCharacteristicsForService = [_delegate respondsToSelector:@selector(xs_peripheral:didDiscoverCharacteristicsForService:error:)];
    _delegateFlags.didUpdateValueForCharacteristic = [_delegate respondsToSelector:@selector(xs_peripheral:didUpdateValueForCharacteristic:error:)];
    _delegateFlags.didWriteValueForCharacteristic = [_delegate respondsToSelector:@selector(xs_peripheral:didWriteValueForCharacteristic:error:)];
    _delegateFlags.didUpdateNotificationStateForCharacteristic = [_delegate respondsToSelector:@selector(xs_peripheral:didUpdateNotificationStateForCharacteristic:error:)];
}

#pragma mark - Public
/** 开始扫描 */
- (void)xs_startScan
{
    XSLogFunc
    
    [_discoveredPeripherals removeAllObjects];
    [_centralManager scanForPeripheralsWithServices:nil options:nil];
    
    // 扫描特定设备
//    [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:UUIDString]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey:@YES }];
//    [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:ServiceUUIDString1], [CBUUID UUIDWithString:ServiceUUIDString2]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey:@YES }];
}

/** 停止扫描 */
- (void)xs_stopScan
{
    XSLogFunc
    [_centralManager stopScan];
}

/** 连接外设 */
- (void)xs_connectPeripheral:(CBPeripheral *)peripheral
{
    XSLogFunc
    NSDictionary *optionDict = [NSDictionary dictionary];
    [_centralManager connectPeripheral:peripheral options:optionDict];
    _peripheral = peripheral;
}

/** 与外设断开连接 */
- (void)xs_disconnectPeripheral:(CBPeripheral *)peripheral
{
    XSLogFunc
    [_centralManager cancelPeripheralConnection:peripheral];
}

/** 寻回外设 (传外设的UUID) */
- (NSArray<CBPeripheral *> *)xs_retrievePeripheralsWithIdentifiers:(NSArray<NSUUID *> *)identifiers
{
    XSLogFunc
    return [_centralManager retrievePeripheralsWithIdentifiers:[NSArray arrayWithObject:identifiers]];
}

#pragma mark - CBCentralManagerDelegate
/** Invoked whenever the central manager's state is updated. */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    XSLogFunc
    if (_delegateFlags.didUpdateState) {
        [self.delegate xs_centralManagerDidUpdateState:central];
    }
}

/** 中心设备恢复调用的方法 */
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict
{
    NSArray *peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey];
    if (peripherals.count) {
        
        if (!_discoveredPeripherals.count) {
            [_discoveredPeripherals addObjectsFromArray:peripherals];
        }
    }
    if (_delegateFlags.willRestoreState) {
        [self.delegate xs_centralManager:central willRestoreState:dict];
    }
    XSLog(@"%@", peripherals);
}

/** Invoked when the central discovers Qpp peripheral while scanning. */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    XSLogFunc
    if (_delegateFlags.didDiscoverPeripheral) {
        [self.delegate xs_centralManager:central didDiscoverPeripheral:aPeripheral advertisementData:advertisementData RSSI:RSSI];
    }
}

/**
 *  Invoked when the central manager retrieves the list of known peripherals.
 Automatically connect to first known peripheral
 */
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    XSLogFunc
    [self xs_stopScan];
    
    /* If there are any known devices, automatically connect to it */
    if ([peripherals count] > 0) {
        _peripheral = [peripherals objectAtIndex:0];
        [_centralManager connectPeripheral:_peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }
}

/**
 *  Invoked whenever a connection is succesfully created with the peripheral.
 Discover available services on the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    XSLogFunc
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    if (_delegateFlags.didConnectPeripheral) {
        [self.delegate xs_centralManager:central didConnectPeripheral:peripheral];
    }
}

/**
 *   Invoked whenever an existing connection with the peripheral is torn down.
 Reset local variables
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    XSLogFunc
    if (peripheral) {
        if (_delegateFlags.didDisconnectPeripheral) {
            [self.delegate xs_centralManager:central didDisconnectPeripheral:peripheral error:error];
        }
        peripheral.delegate = nil;
        peripheral = nil;
    }
}

/**
 *  Invoked whenever the central manager fails to create a connection
 with the peripheral.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    XSLogFunc
    if (peripheral) {
        if (_delegateFlags.didFailToConnectPeripheral) {
            [self.delegate xs_centralManager:central didFailToConnectPeripheral:peripheral error:error];
        }
        peripheral.delegate = nil;
        peripheral = nil;
    }
}

#pragma mark - CBPeripheralDelegate
/**
 *  Invoked upon completion of a -[discoverServices:] request.
 Discover available characteristics on interested services
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    XSLogFunc
    [_discoveredServices removeAllObjects];
    
    for (CBService *aService in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:aService];
        
        if( ![_discoveredServices containsObject:aService] ) {
            [_discoveredServices addObject:aService];
        }
    }
    if (_delegateFlags.didDiscoverServices) {
        [self.delegate xs_peripheral:peripheral didDiscoverServices:error];
    }
}

/**
 *  Invoked upon completion of a -[discoverCharacteristics:forService:] request.
 Perform appropriate operations on interested characteristics
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    XSLogFunc
    if (_delegateFlags.didDiscoverCharacteristicsForService) {
        [self.delegate xs_peripheral:peripheral didDiscoverCharacteristicsForService:service error:error];
    }
}

/**
 *  Invoked upon completion of a -[updateValueForCharacteristic:]
 request or on the reception of a notification/indication.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    XSLogFunc
    if (_delegateFlags.didUpdateValueForCharacteristic) {
        [self.delegate xs_peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
    }
}

/** 数据写入是否成功 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!_upgradeMode) { // 当前不是OTA升级模式
        if (_delegateFlags.didWriteValueForCharacteristic) {
            [self.delegate xs_peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
        }
    }
}

/** 设置数据订阅成功（或失败） */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (_delegateFlags.didUpdateNotificationStateForCharacteristic) {
        [self.delegate xs_peripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic error:error];
    }
}

@end

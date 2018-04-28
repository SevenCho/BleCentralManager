//
//  ViewController.m
//  BleCentralManager
//
//  Created by 曹雪松 on 2018/4/28.
//  Copyright © 2018 曹雪松. All rights reserved.
//

#import "ViewController.h"
#import "XSPeripheralsViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#import "XSBleManager.h"

#import "XSPeripheral.h"

@interface ViewController () <XSBleManagerDelegate>

@property (weak, nonatomic) XSPeripheralsViewController *peripheralsVC;
@property (weak, nonatomic) IBOutlet UILabel *stateLbl;

@property (nonatomic, weak) CBPeripheral *connectedperipheral;

@property (nonatomic, strong) NSMutableArray <XSPeripheral *> *peripherals;
@property (nonatomic, strong) XSBleManager *bleManager;

@end

@implementation ViewController

#pragma mark - Setters & Getters
- (NSMutableArray<XSPeripheral *> *)peripherals
{
    if (!_peripherals) {
        self.peripherals = [NSMutableArray array];
    }
    return _peripherals;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.bleManager = [XSBleManager manager];
    self.bleManager.delegate = self;
}

- (IBAction)startScan:(UIButton *)sender
{
    [self.peripherals removeAllObjects];
    XSPeripheralsViewController *peripheralsVC = [[XSPeripheralsViewController alloc] init];
    _peripheralsVC = peripheralsVC;
    __weak __typeof(self)weakSelf = self;
    peripheralsVC.connectPeripheralHander = ^(XSPeripheral *peripheralModel) {
        [weakSelf.bleManager xs_stopScan];
        [weakSelf.bleManager xs_connectPeripheral:peripheralModel.peripheral];
    };
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:peripheralsVC] animated:YES completion:^{
        [self.bleManager xs_startScan];
    }];
}

- (IBAction)disconnectPeripheral:(UIButton *)sender
{
    if (!_connectedperipheral) {
        return;
    }
    [self.bleManager xs_disconnectPeripheral:_connectedperipheral];
}

#pragma mark - XSBleManagerDelegate
- (void)xs_centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBManagerStatePoweredOn) {
        XSLog(@"蓝牙可用, 点击开始扫描");
        
    } else {
        XSLog(@"蓝牙不可用😈😈");
    }
}

- (void)xs_centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    XSLog(@"%@", peripheral.name);
    
    XSPeripheral *peripheralModel = [[XSPeripheral alloc] init];
//    peripheralModel.peripheralName = peripheral.name;
    NSString *peripherallName = [advertisementData valueForKey:@"kCBAdvDataLocalName"]; // 这个蓝牙名称刷新比较快 比较准确 (有时候蓝牙设备修改名称 peripheral.name 不会立即刷新)
    peripheralModel.peripheralName = peripherallName;
    peripheralModel.peripheralRssi = RSSI.stringValue;
    NSString *stateSting = nil;
    switch (peripheral.state) {
        case CBPeripheralStateDisconnected:
            stateSting = @"Disconnected";
            break;
        case CBPeripheralStateConnecting:
            stateSting = @"Connecting";
            break;
        case CBPeripheralStateConnected:
            stateSting = @"Connected";
            break;
        case CBPeripheralStateDisconnecting:
            stateSting = @"Disconnecting";
            break;
    }
    peripheralModel.peripheralState = stateSting;
    peripheralModel.peripheralIdentity = peripheral.identifier.UUIDString;
    peripheralModel.peripheral = peripheral;
    [self.peripherals addObject:peripheralModel];
    _peripheralsVC.peripherals = self.peripherals;
}

- (void)xs_centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    _connectedperipheral = peripheral;
    _stateLbl.text = [NSString stringWithFormat:@"外设：%@ 已连接", peripheral.name];
}

- (void)xs_centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    _stateLbl.text = [NSString stringWithFormat:@"外设：%@ 已断开", peripheral.name];
}

- (void)xs_peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    XSLogFunc
}

- (void)xs_peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    XSLogFunc
    if (error) {
        XSLog(@"搜索Characteristic失败:%@", peripheral.services);
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        XSLog(@"搜索到的服务：%@ 对应的所有：Characteristic:%@", service, characteristic);
        
        // 具体的特征值的作用请参考公司文档或者和公司硬件工程师沟通
        // 可订阅的特征
//        if ([characteristic.UUID.UUIDString isEqualToString:CharacteristicNotifyUUIDString]) {
//            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//
//        }

        // OTA升级特征
//        if ([characteristic.UUID.UUIDString isEqual:CharacteristicWriteOTAUUIDString]) {
//
//        }
        
        // 可写的特征
//        if ([characteristic.UUID.UUIDString isEqual:CharacteristicWriteUUIDString]) {
//
//        }
    }
}

- (void)xs_peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    XSLogFunc
    // 连接的蓝牙设备发送数据会在这里接收
    
    // 写入数据方式
    // [_connectedPeripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}

- (void)xs_peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    XSLogFunc
    // 每包数据写入成功， 回调这里 (蓝牙数据发送需要分包 拆分为每包16个字节发送)
}

- (void)xs_peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
  XSLogFunc
    // 订阅特征值成功，有更新回调这里
}

@end

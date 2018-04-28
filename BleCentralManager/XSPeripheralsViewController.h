//
//  XSPeripheralListViewController.h
//  BleCentralManager
//
//  Created by 曹雪松 on 2018/4/28.
//  Copyright © 2018 曹雪松. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XSPeripheral;

typedef void (^XSConnectPeripheralHander)(XSPeripheral *peripheralModel);

@interface XSPeripheralsViewController : UITableViewController

@property (nonatomic, strong) NSArray <XSPeripheral *> *peripherals;
@property (nonatomic, copy)  XSConnectPeripheralHander connectPeripheralHander;

@end

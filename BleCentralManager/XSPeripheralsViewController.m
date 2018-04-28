//
//  XSPeripheralListViewController.m
//  BleCentralManager
//
//  Created by 曹雪松 on 2018/4/28.
//  Copyright © 2018 曹雪松. All rights reserved.
//

#import "XSPeripheralsViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#import "XSPeripheralCell.h"

@interface XSPeripheralsViewController ()

@end

@implementation XSPeripheralsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)setPeripherals:(NSArray<XSPeripheral *> *)peripherals
{
    _peripherals = peripherals;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _peripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XSPeripheralCell *cell = [XSPeripheralCell cellWithTableView:tableView];
    cell.peripheral = _peripherals[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_connectPeripheralHander) {
        _connectPeripheralHander(_peripherals[indexPath.row]);
    }
    self.connectPeripheralHander = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

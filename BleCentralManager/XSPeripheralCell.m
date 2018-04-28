//
//  PeripheralCell.m
//  BleCentralManager
//
//  Created by 曹雪松 on 2018/4/28.
//  Copyright © 2018 曹雪松. All rights reserved.
//

#import "XSPeripheralCell.h"
#import "XSPeripheral.h"

@interface XSPeripheralCell ()

@property (weak, nonatomic) IBOutlet UILabel *peripheralNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *peripheralIdentityLbl;
@property (weak, nonatomic) IBOutlet UILabel *peripheralStateLbl;
@property (weak, nonatomic) IBOutlet UILabel *peripheralRssiLbl;

@end

@implementation XSPeripheralCell

+ (XSPeripheralCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"XSPeripheralCell";
    XSPeripheralCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil].firstObject;
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setPeripheral:(XSPeripheral *)peripheral
{
    _peripheral = peripheral;
    
    _peripheralNameLbl.text = peripheral.peripheralName;
    _peripheralIdentityLbl.text = peripheral.peripheralIdentity;
    _peripheralStateLbl.text = peripheral.peripheralState;
    _peripheralRssiLbl.text = peripheral.peripheralRssi;
}

@end

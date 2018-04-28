//
//  PeripheralCell.h
//  BleCentralManager
//
//  Created by 曹雪松 on 2018/4/28.
//  Copyright © 2018 曹雪松. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XSPeripheral;

@interface XSPeripheralCell : UITableViewCell

+ (XSPeripheralCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) XSPeripheral *peripheral;

@end

//
//  SettingViewController.h
//  XpaiLiving
//
//  Created by xuming on 13-09-27.
//  Copyright (c) 2013年 沃安科技 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray       * _dataSourceArray;
}
@property(nonatomic,retain)IBOutlet UITableView * settingTableView;

@end

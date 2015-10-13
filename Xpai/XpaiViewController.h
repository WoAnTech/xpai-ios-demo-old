//
//  XpaiViewController.h
//  Xpai
//
//  Created by 徐功伟 on 13-04-01.
//  Copyright 2011年 沃安科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XpaiViewController : UIViewController<UITableViewDataSource,UITableViewDelegate> {
    NSMutableArray *dataSourceAry;
}
@property (nonatomic, retain) IBOutlet UITableView *cTableView;
@end

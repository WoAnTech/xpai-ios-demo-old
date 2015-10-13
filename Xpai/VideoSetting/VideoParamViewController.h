//
//  VideoParamViewController.h
//  HangZhouPO
//
//  Created by xuming on 13-09-27.
//  Copyright (c) 2013年 沃安科技 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoParamViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray* _dataSourceArray;
    long _currentResolution;
}

@property (nonatomic, retain) IBOutlet UITableView* videoParamtableView;

@end

//
//  VideoRecordModeController.h
//  HangZhouPO
//
//  Created by xuming on 13-09-27.
//  Copyright (c) 2013年 沃安科技 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoRecordModeController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    
    NSMutableArray* _dataSourceArray;
    long _curRercodMode;
}

@property (nonatomic, retain) IBOutlet UITableView* recordModetableView;
@end

//
//  VideoRecordModeController.m
//  HangZhouPO
//
//  Created by xuming on 13-09-27.
//  Copyright (c) 2013年 沃安科技 . All rights reserved.
//

#import "VideoRecordModeController.h"
#import "SettingConfig.h"

@interface VideoRecordModeController ()

@end

@implementation VideoRecordModeController

@synthesize recordModetableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = NSLocalizedString(@"视频录制模式", nil);
        self.navigationItem.hidesBackButton = YES;
        UIBarButtonItem* leftItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
        self.navigationItem.leftBarButtonItem = leftItem;
        [leftItem release];
        
        _dataSourceArray = [[NSMutableArray alloc]init];
        [_dataSourceArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"软编直播",@"kName", @"硬编数据保存至本地，软编数据上传", @"kDesc", nil]];
        [_dataSourceArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"IOS8优化",@"kName", @"硬编延迟问题的优化，仅IOS8以上支持", @"kDesc", nil]];
    }
    return self;
}

- (void)backAction:(id)sender
{
    [SettingConfig sharedInstance]._recordMode = _curRercodMode +3;
    [[SettingConfig sharedInstance] WriteDataToFile];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _curRercodMode = [SettingConfig sharedInstance]._recordMode -3;
}

- (void)dealloc
{
    [recordModetableView release];
    [_dataSourceArray release];
    [super dealloc];
}

#pragma mark -
#pragma mark Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSourceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"VideoRecordModeTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [[_dataSourceArray objectAtIndex:indexPath.row] objectForKey:@"kName"];
    cell.detailTextLabel.text = [[_dataSourceArray objectAtIndex:indexPath.row]objectForKey:@"kDesc"];

    if(_curRercodMode==indexPath.row)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    [self exchangeItems:tableView indexPath:indexPath];
}

#pragma mark - other functions
- (void)exchangeItems:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath
{
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:_curRercodMode inSection:0];
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    
    oldCell.accessoryType = UITableViewCellAccessoryNone;
    newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    _curRercodMode = indexPath.row;
}

@end

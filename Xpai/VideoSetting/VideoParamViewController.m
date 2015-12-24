//
//  VideoParamViewController.m
//  HangZhouPO
//
//  Created by xuming on 13-09-27.
//  Copyright (c) 2013年 沃安科技 . All rights reserved.
//

#import "VideoParamViewController.h"
#import "SettingConfig.h"

@implementation VideoParamViewController

@synthesize videoParamtableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"视频分辨率", nil);
        self.navigationItem.hidesBackButton = YES;
        UIBarButtonItem* leftItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
        self.navigationItem.leftBarButtonItem = leftItem;
        [leftItem release];
        
        _dataSourceArray = [[NSMutableArray alloc]init];
        [_dataSourceArray addObject:@"LOW (192*144)"];
        [_dataSourceArray addObject:@"MEDIUM (480*360)"];
        [_dataSourceArray addObject:@"VGA (640*480)"];
        [_dataSourceArray addObject:@"HIGH (1280*720)"];
    }
    return self;
}

- (void)backAction:(id)sender
{
    [SettingConfig sharedInstance]._videoResolution = _currentResolution;
    [[SettingConfig sharedInstance] WriteDataToFile];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _currentResolution = [SettingConfig sharedInstance]._videoResolution;
}

- (void)dealloc
{
    [videoParamtableView release];
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
    static NSString *CellIdentifier = @"VideoParamViewTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [_dataSourceArray objectAtIndex:indexPath.row];

    if(_currentResolution==indexPath.row)
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
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:_currentResolution inSection:0];
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    
    oldCell.accessoryType = UITableViewCellAccessoryNone;
    newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    _currentResolution = indexPath.row;
    switch (_currentResolution) {
        case 0:
            [SettingConfig sharedInstance]._videoBitrate = 192;
            break;
        case 1:
            [SettingConfig sharedInstance]._videoBitrate = 480;
            break;
        case 2:
            [SettingConfig sharedInstance]._videoBitrate = 640;
            break;
        case 3:
            [SettingConfig sharedInstance]._videoBitrate = 1280;
            break;
        default:
            break;
    }
}

-(BOOL)shouldAutorotate
{
    return NO;
}
@end

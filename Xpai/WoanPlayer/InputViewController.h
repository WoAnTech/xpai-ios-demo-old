//
//  RootViewController.h
//  WoanPlayerDemo
//
//  Created by 北京沃安科技有限公司 on 4/18/14.
//  Copyright (c) 2014 xuming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputViewController : UIViewController{

}

@property (nonatomic, retain) IBOutlet UITextField *textField;

- (IBAction)playAction:(id)sender;
- (IBAction)textFieldDoneEditing:(id)sender;
@end

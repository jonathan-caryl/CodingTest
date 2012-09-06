//
//  ViewController.h
//  PinterTest
//
//  Created by Jonathan Caryl on 06/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "User.h"
#import "Item.h"

@interface ViewController : UIViewController <UserDelegate, ItemDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *viewBlocking;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

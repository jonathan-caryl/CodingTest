//
//  ItemCell.h
//  PinterTest
//
//  Created by Jonathan Caryl on 06/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemCell : UITableViewCell


@property (nonatomic, strong) IBOutlet UILabel *labelUsername;

@property (strong, nonatomic) IBOutlet UILabel *labelDescription;
@property (strong, nonatomic) IBOutlet UILabel *labelAttrib;

@property (strong, nonatomic) IBOutlet UIImageView *imageViewSrc;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewUser;

@end

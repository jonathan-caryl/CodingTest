//
//  Item.h
//  PinterTest
//
//  Created by Jonathan Caryl on 06/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "User.h"

@class Item;

@protocol ItemDelegate <NSObject>

- (void)itemDidLoadHref:(Item *)gtGistItem;

@end


@interface Item : NSObject

- (id)initFromDictionary:(NSDictionary *)dictionary;
- (void)loadHref;

@property (nonatomic, strong) id <ItemDelegate> delegate;

@property (nonatomic, strong) NSString *href;
@property (nonatomic, strong) NSString *src;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *attrib;
@property (nonatomic, strong) UIImage *imageSrc;
@property (nonatomic, strong) User *user;

@end

//
//  User.h
//  PinterTest
//
//  Created by Jonathan Caryl on 06/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@protocol UserDelegate <NSObject>

- (void)userDidLoadAvatar:(User *)user;

@end

@interface User : NSObject;

- (id)initFromDictionary:(NSDictionary *)dictionary;
- (void)loadAvatarImage;

@property (nonatomic, strong) id <UserDelegate> delegate;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *avatarSrc;
@property (nonatomic, strong) UIImage *avatarImage;

@end
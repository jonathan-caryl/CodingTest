//
//  User.m
//  PinterTest
//
//  Created by Jonathan Caryl on 06/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User.h"

@interface User ()

@property (nonatomic, readwrite) CGSize avatarSize;
@end

@implementation User

@synthesize avatarSize;
@synthesize delegate;
@synthesize username;
@synthesize name;
@synthesize avatarSrc;
@synthesize avatarImage;


- (id)initFromDictionary:(NSDictionary *)dictionary avatarSize:(CGSize)_size
{
    self = [super init];
	if (nil != self)
    {
        avatarSize = _size;
        username = [dictionary objectForKey:@"username"];
        name     = [dictionary objectForKey:@"name"];
        NSDictionary *avatarDictionary = [dictionary objectForKey:@"avatar"];
        avatarSrc = [avatarDictionary objectForKey:@"src"];
    }
    
    return self;
}

- (void)loadAvatarImage
{
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(q, ^{
        UIImage * img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarSrc]]];
        
        if (nil != img)
        {
            avatarImage = img;
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               [delegate userDidLoadAvatar:self];
                           });
            
        }
    });
}
@end

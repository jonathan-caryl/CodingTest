//
//  Item.m
//  PinterTest
//
//  Created by Jonathan Caryl on 06/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Item.h"

@implementation Item

@synthesize delegate;
@synthesize imageSrc;
@synthesize href;
@synthesize src;
@synthesize desc;
@synthesize attrib;
@synthesize user;

- (id)initFromDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (nil != self)
    {
        href = [dictionary objectForKey:@"href"];
        src  = [dictionary objectForKey:@"src"];
        desc = [dictionary objectForKey:@"desc"];
        attrib = [dictionary objectForKey:@"attrib"];
    }
    
    return self;
}

- (void)loadHref
{
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(q, ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:src]];
        UIImage * img = [[UIImage alloc] initWithData:data];
        
        if (nil != img)
        {
            imageSrc = img;
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               [delegate itemDidLoadHref:self];
                           });
            
        }
    });
    
}
@end

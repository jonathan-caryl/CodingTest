//
//  ViewController.m
//  PinterTest
//
//  Created by Jonathan Caryl on 06/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

- (void) loadJson;
- (void) jsonLoaded:(NSData *)data;
- (void) jsonError:(NSError *)error;

@property (nonatomic, strong) NSMutableArray      *arrayItems;
@property (nonatomic, strong) NSMutableDictionary *userDictionary;

@end

@implementation ViewController

@synthesize arrayItems;
@synthesize userDictionary;
@synthesize tableView;
@synthesize viewBlocking;
@synthesize activityIndicator;


- (void) jsonLoaded:(NSData *)data
{
    if (nil == data)
        [self jsonError:nil];
    
    NSError *e = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
    userDictionary = [[NSMutableDictionary alloc] initWithCapacity:jsonArray.count];
    
    arrayItems = [[NSMutableArray alloc] initWithCapacity:jsonArray.count];
    
    for (NSDictionary *dict in jsonArray)
    {
        NSDictionary *userDict = [dict objectForKey:@"user"];
        User *user = [[User alloc] initFromDictionary:userDict avatarSize:CGSizeMake(25.0, 25.0)];
        User *existingUser = [userDictionary objectForKey:user.username];
        if (nil == existingUser)
            [userDictionary setObject:user forKey:user.username];
        
        Item *item = [[Item alloc] initFromDictionary:dict];
        item.user = user;
        item.delegate = self;
        [item loadHref];
        
        [arrayItems addObject:item];
    }
    
    if (!jsonArray) {
        NSLog(@"Error parsing JSON: %@", e);
        [self jsonError:nil];
    } else {
        [self.tableView reloadData];
        [UIView beginAnimations:@"hideBlocking" context:NULL];
        
        viewBlocking.alpha = 0.0;
        [activityIndicator stopAnimating];
        [UIView commitAnimations];
    }    
}

- (void) jsonError:(NSError *)error
{
    [UIView beginAnimations:@"error" context:NULL];
    self.activityIndicator.alpha = 0.0;
    
    [UIView commitAnimations];
}


- (IBAction)reloadJson:(id)sender {
    [UIView beginAnimations:@"reload" context:NULL];
    self.activityIndicator.alpha = 1.0;
    
    [UIView commitAnimations];
    [self loadJson];
}

- (void) loadJson
{
    static NSString *jsonUrl = @"http://warm-eyrie-4354.herokuapp.com/feed.json";
    
    
    NSURL *url = [NSURL URLWithString:jsonUrl];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil)
             [self jsonLoaded:data];
         else if ([data length] == 0 && error == nil)
             [self jsonError:nil];
         else if (error != nil)
             [self jsonError:error];
     }];    
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self loadJson];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setViewBlocking:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark UITableViewDelegate methods
- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = indexPath.row;
    
    Item *item = [arrayItems objectAtIndex:row];
    
    NSURL *url = [NSURL URLWithString:item.href];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (nil == arrayItems)
        return 0;
    
    return [arrayItems count];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NSString *cellIdentifier;
    NSInteger row     = indexPath.row;
    
    cellIdentifier = CellIdentifier;
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell.
    Item *item = [arrayItems objectAtIndex:row];
    cell.textLabel.text = item.desc;
    
    return cell;
}

#pragma mark GTGistUserDelegate methods
- (void)userDidLoadAvatar:(User *)user
{
    [self.tableView reloadData];
}

#pragma mark GTGistItemDelegate methods
- (void)itemDidLoadHref:(Item *)item
{
    [self.tableView reloadData];
}


@end

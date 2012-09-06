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
- (void) jsonErrorString:(NSString *)string;

@property (nonatomic, strong) NSMutableArray      *arrayItems;
@property (nonatomic, strong) NSMutableDictionary *userDictionary;
@property (nonatomic, readwrite) CGFloat           cellHeight;

@end

@implementation ViewController

@synthesize arrayItems;
@synthesize userDictionary;
@synthesize cellHeight;
@synthesize tableView;
@synthesize viewBlocking;
@synthesize activityIndicator;
@synthesize buttonRetry;
@synthesize labelError;
@synthesize tmpCell;

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
        {
            user.delegate = self;
            [userDictionary setObject:user forKey:user.username];
            existingUser = user;
        }
        
        Item *item = [[Item alloc] initFromDictionary:dict];
        item.user = existingUser;
        item.delegate = self;
        
        [arrayItems addObject:item];
    }
    
    if (!jsonArray) {
        NSLog(@"Error parsing JSON: %@", e);
        [self jsonError:e];
    } else {
        // Get the height for the table cells from our cell NIB
		[[NSBundle mainBundle] loadNibNamed:@"ItemCell" owner:self options:nil];
        cellHeight = tmpCell.frame.size.height;
        tmpCell = nil;
        
        [self.tableView reloadData];
        [UIView beginAnimations:@"hideBlocking" context:NULL];
        
        viewBlocking.alpha = 0.0;
        [activityIndicator stopAnimating];
        [UIView commitAnimations];
        
        NSArray *arrayUsers = [userDictionary allValues];
        for (User *user in arrayUsers)
        {
            [user loadAvatarImage];
        }
        
        for (Item *item in arrayItems)
        {
            [item loadHref];
        }
    }    
}

- (void) jsonError:(NSError *)error
{
    [self jsonErrorString:error.localizedDescription];
}

- (void) jsonErrorString:(NSString *)string
{
    self.labelError.text = string;
    
    [UIView beginAnimations:@"error" context:NULL];
    self.activityIndicator.alpha = 0.0;
    self.buttonRetry.alpha = 1.0;
    self.labelError.alpha = 1.0;
    
    [UIView commitAnimations];
}


- (IBAction)reloadJson:(id)sender {
    [UIView beginAnimations:@"reload" context:NULL];
    self.activityIndicator.alpha = 1.0;
    self.buttonRetry.alpha = 0.0;
    self.labelError.alpha = 0.0;
    
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
             [self jsonErrorString:@"No data downloaded"];
         else if (error != nil && error.code == NSURLErrorTimedOut)
             [self jsonError:error];
         else if (error != nil)
             [self jsonError:error];
     }];    
}


- (IBAction)retryPressed:(id)sender {
    [self loadJson];
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
    [self setButtonRetry:nil];
    [self setLabelError:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

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
    
    ItemCell *cell = (ItemCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
		[[NSBundle mainBundle] loadNibNamed:@"ItemCell" owner:self options:nil];
		cell = tmpCell;
		self.tmpCell = nil;
    }
    
    // Configure the cell.
    Item *item = [arrayItems objectAtIndex:row];
    cell.labelUsername.text = item.user.username;
    cell.labelAttrib.text = item.attrib;
    cell.labelDescription.text = item.desc;
    cell.imageViewUser.image = item.user.avatarImage;
    cell.imageViewSrc.image = item.imageSrc;
    
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

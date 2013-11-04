//
//  CMCommentViewController.m
//  ComicMaster
//
//  Created by Hang Li on 8/18/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "CMCommentViewController.h"
#import "CMComment.h"
#include "CMAppDelegate.h"
#import "SBJson.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "CMCommentCell.h"
#import "Base64.h"

@interface CMCommentViewController ()
{
    NSMutableArray *_comments;
    NSMutableArray *_filteredComments;
}
@end

@implementation CMCommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _comments = [[NSMutableArray alloc] init];
    _filteredComments = [[NSMutableArray alloc] init];
    [self retrieveCommentsByComicId:_curComicId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return _filteredComments.count;
    }
    
    else {
        return _comments.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"commentCell";
    // must use 'self.commentTableView' instead of the 'tableView' parameter to avoid returning nil cell 
    CMCommentCell *cell = [self.commentTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    CMComment *comment;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        comment = _filteredComments[indexPath.row];
    } else {
        comment = _comments[indexPath.row];
    }
    
    cell.authorNameLabel.text = comment.user.userName;
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateString = [gmtDateFormatter stringFromDate:comment.commentTime];
    cell.commentTimeLabel.text = dateString;
    cell.contentLabel.text = comment.content;
    cell.authorImageView.layer.cornerRadius = 4;
    cell.authorImageView.layer.borderWidth = 2;
    cell.authorImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.authorImageView.image = comment.user.avatar;
    return cell;
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addComment:(id)sender
{
    UIAlertView *commentInputAlert = [[UIAlertView alloc] initWithTitle:@"Wanna say something?" message:@"enter comments" delegate:self cancelButtonTitle:@"Wait..." otherButtonTitles:@"That's it", nil];
    [commentInputAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [commentInputAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    CMComment *comment = [[CMComment alloc] init];
    comment.content = [alertView textFieldAtIndex:0].text;
    comment.user = ((CMAppDelegate *)[[UIApplication sharedApplication] delegate]).loginUser;
    comment.comicId = _curComicId;
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateString = [gmtDateFormatter stringFromDate:[NSDate date]];
    // send request
    NSURL *url = [NSURL URLWithString:@"http://localhost/~hang/comicMaster/insertComment.php"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.delegate = self;
    [request setRequestMethod:@"POST"];
    NSString *comicIdStr = [NSString stringWithFormat:@"%i", comment.comicId];
    [request addPostValue:comicIdStr forKey:@"comicId"];
    [request addPostValue:comment.user.userName forKey:@"authorName"];
    [request addPostValue:comment.content forKey:@"content"];
    [request addPostValue:dateString forKey:@"commentTime"];
    [request startAsynchronous];
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    if ([request.responseString isEqualToString:@"comment added"]) {
        [self retrieveCommentsByComicId:_curComicId];
        return;
    }
    NSString *resStr = request.responseString;
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSArray *jsonObjects = [parser objectWithString:resStr error:nil];
    [_comments removeAllObjects];
    
    for (NSDictionary *jsonObj in jsonObjects) {
        CMComment *comment = [[CMComment alloc] init];
        comment.comicId = [((NSString *)[jsonObj objectForKey:@"comicId"]) integerValue];
        comment.user = [[CMUser alloc] init];
        comment.user.userName = [jsonObj objectForKey:@"username"];
        NSString *imgStr = [jsonObj objectForKey:@"avatar"];
        NSData *imgData = [Base64 decode:imgStr];
        UIImage *curImage = [UIImage imageWithData:imgData];
        comment.user.avatar = curImage;
        comment.content = [jsonObj objectForKey:@"content"];
        NSString *dateString = [jsonObj objectForKey:@"commentTime"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        comment.commentTime = [formatter dateFromString:dateString];
        [_comments addObject:comment];
    }
    [self.commentTableView reloadData];
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"request failed");
}

- (void)retrieveCommentsByComicId:(NSInteger)comicId
{
    NSString *urlStr = [NSString stringWithFormat:@"http://localhost/~hang/comicMaster/listCommentsByComicId.php?comicId=%i", comicId];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.delegate = self;
    [request setRequestMethod:@"GET"];
    [request startAsynchronous];
}

#pragma mark - for searching
- (void) filterForSearch:(NSString *)searchText scope:(NSString *)scope
{
    [_filteredComments removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.user.userName contains[cd] %@", searchText];
    _filteredComments = [NSMutableArray arrayWithArray:[_comments filteredArrayUsingPredicate:predicate]];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterForSearch:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES; // cause search result table view to reload
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterForSearch:self.searchDisplayController.searchBar.text scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}
@end

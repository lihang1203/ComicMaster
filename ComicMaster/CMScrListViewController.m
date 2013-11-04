//
//  CMScrListViewController.m
//  ComicMaster
//
//  Created by Hang Li on 8/8/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CMScrListViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJson.h"
#import "Base64.h"
#import "CMComic.h"
#import "CMComicCell.h"
#import "CMAppDelegate.h"
#import "CMCommentViewController.h"

const int PAGESIZE = 5;

@interface CMScrListViewController ()
{
    NSMutableArray *_comicList;
    NSInteger _curPage;
    NSInteger _totalPage;
    BOOL _isLoading;
    NSInteger _curComicId;
}
@end

@implementation CMScrListViewController

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
    self.actIndicator.hidden = NO;
	_comicList = [[NSMutableArray alloc] init];
    _curPage = 1;
    [self retrieveComicsAtPage:_curPage withPageSize:PAGESIZE];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _comicList.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CMComicCell *comicCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"comicCell" forIndexPath:indexPath];
    comicCell.backgroundColor = [UIColor whiteColor];
    CMComic *curComic = [_comicList objectAtIndex:indexPath.row];
    comicCell.comicCellImgView.image = curComic.image;
    comicCell.comicTitleLabel.text = curComic.title;
    comicCell.comicAuthorLabel.text = curComic.author.userName;
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateString = [gmtDateFormatter stringFromDate:curComic.updateTime];
    comicCell.comicUploadTimeLabel.text = dateString;
    comicCell.comicContentView.layer.borderColor = [UIColor grayColor].CGColor;
    comicCell.comicContentView.layer.borderWidth = 3.0f;
    comicCell.comicContentView.layer.cornerRadius = 8;
    comicCell.comicTitleLabel.layer.borderColor = [UIColor grayColor].CGColor;
    comicCell.comicTitleLabel.layer.borderWidth = 3.0f;
    comicCell.comicTitleLabel.layer.cornerRadius = 8;
    comicCell.comicTitleLabel.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    comicCell.comicBottomBarView.layer.borderColor = [UIColor grayColor].CGColor;
    comicCell.comicBottomBarView.layer.borderWidth = 3.0f;
    comicCell.comicBottomBarView.layer.cornerRadius = 8;
    comicCell.comicBottomBarView.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    comicCell.commentButton.curComicId = curComic.comicId;
    comicCell.comicAuthorAvatarImgView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    comicCell.comicAuthorAvatarImgView.layer.borderWidth = 2.0f;
    comicCell.comicAuthorAvatarImgView.layer.cornerRadius = 5;
    comicCell.comicAuthorAvatarImgView.image = curComic.author.avatar;
    return comicCell;
}

- (void)retrieveComicsAtPage:(NSInteger)page withPageSize:(NSInteger)pageSize
{
    [self.actIndicator startAnimating];
    NSString *urlStr = [NSString stringWithFormat:@"http://localhost/~hang/comicMaster/listComicPage.php?page=%i&pageSize=%i", page, pageSize];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.delegate = self;
    [request setRequestMethod:@"GET"];
    [request startSynchronous];
    NSString *resStr = request.responseString;
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSArray *jsonObjects = [parser objectWithString:resStr error:nil];
    //    [_comicList removeAllObjects];
    int oldCount = _comicList.count;
    for (NSDictionary *jsonObj in jsonObjects) {
        NSString *imgStr = [jsonObj objectForKey:@"image"];
        NSData *imgData = [Base64 decode:imgStr];
        UIImage *curImage = [UIImage imageWithData:imgData];
        CMComic *comic = [[CMComic alloc] init];
        comic.author = [[CMUser alloc] init];
        comic.comicId = [((NSString *)[jsonObj objectForKey:@"id"]) integerValue];
        comic.image = curImage;
        comic.title = [jsonObj objectForKey:@"title"];
        comic.author.userName = [jsonObj objectForKey:@"username"];
        NSString *avatarStr = [jsonObj objectForKey:@"avatar"];
        NSData *avatarData = [Base64 decode:avatarStr];
        UIImage *avatarImg = [UIImage imageWithData:avatarData];
        comic.author.avatar = avatarImg;
        NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
        gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        comic.updateTime = [gmtDateFormatter dateFromString:[jsonObj objectForKey:@"uploadtime"]];
        [_comicList addObject:comic];
    }
    [self.actIndicator stopAnimating];
    if (_comicList.count > oldCount) {
        [self.comicListCollectionView reloadData];
    }
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    // do sth
}

-(void) showAlert:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)reload:(id)sender
{
    [[self comicListCollectionView] setContentOffset:CGPointZero animated:NO];
    _curPage = 1;
    [_comicList removeAllObjects];
    [self retrieveComicsAtPage:_curPage withPageSize:PAGESIZE];
}

- (IBAction)commentClicked:(CMCommentButton *)sender
{
    if (((CMAppDelegate *)[[UIApplication sharedApplication] delegate]).loginUser == nil) {
        
        [self performSegueWithIdentifier:@"list2login" sender:self];
    } else {
        _curComicId = sender.curComicId;
        [self performSegueWithIdentifier:@"list2comment" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"list2comment"]) {
        ((CMCommentViewController *)segue.destinationViewController).curComicId = _curComicId;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
    {
        if (!_isLoading)
        {
            _isLoading = YES;
            NSLog(@"loading");
            [self retrieveComicsAtPage:++_curPage withPageSize:PAGESIZE];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_isLoading) {
        _isLoading = NO;
    }
}

@end

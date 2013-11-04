//
//  CMCollectionViewController.m
//  ComicMaster
//
//  Created by Hang Li on 8/9/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import "CMCollectionViewController.h"
#include "CMImageCell.h"
#include "CMImageViewController.h"
#include "CMComic.h"
#include "CMComicDAO.h"
#include "CMCanvasViewController.h"
#include "CMAppDelegate.h"
#import "CMLoginViewController.h"

@interface CMCollectionViewController ()
{
    NSMutableArray *_localComics;
}
@end

@implementation CMCollectionViewController

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
}

- (void)viewDidAppear:(BOOL)animated
{
    CMUser *curUser = ((CMAppDelegate *)[[UIApplication sharedApplication] delegate]).loginUser;
    if (curUser != nil) {
        _localComics = [[CMComicDAO getInstance] listAllByUser:curUser.userName];
        [self.imgCollectionView reloadData];
    } else {
        [_localComics removeAllObjects];
        [self.imgCollectionView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _localComics.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CMImageCell *imgCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imgCell" forIndexPath:indexPath];
    imgCell.backgroundColor = [UIColor whiteColor];
    CMComic *curComic = [_localComics objectAtIndex:indexPath.row];
    imgCell.imgView.image = curComic.image;
    imgCell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame.png"]];
    return imgCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CMComic *selComic = ((CMComic *)_localComics[indexPath.row]);
    [self performSegueWithIdentifier:@"showImage" sender:selComic];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showImage"]) {
        ((CMImageViewController *)segue.destinationViewController).comic = (CMComic *)sender;
        ((CMImageViewController *)segue.destinationViewController).prevVC = self;
    } else if ([segue.identifier isEqualToString:@"gotoCanvas"]) {
        if ([sender isKindOfClass:[CMComic class]]) {
            CMComic *curComic = (CMComic *)sender;
            if (curComic.image) {
                ((CMCanvasViewController *)segue.destinationViewController).curComic = curComic;
            }
        }
    }
}

- (IBAction)newComicSelected:(id)sender
{
    if (((CMAppDelegate *)[[UIApplication sharedApplication] delegate]).loginUser == nil) {
        [self performSegueWithIdentifier:@"studio2login" sender:self];
    } else {
        [self performSegueWithIdentifier:@"gotoCanvas" sender:self];
    }
}
@end

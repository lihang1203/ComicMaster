//
//  CMComicLibViewController.m
//  ComicMaster
//
//  Created by Hang Li on 8/10/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import "CMComicLibViewController.h"
#import "CMImageCell.h"

static NSMutableArray *_comicElements;

@interface CMComicLibViewController ()

@end

@implementation CMComicLibViewController

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
    if (_comicElements == nil) {
        _comicElements = [[NSMutableArray alloc] init];
        for (int i = 1; i <= 22; ++i) {
            NSString *imgName = [NSString stringWithFormat:@"face%i.jpg", i];
            [_comicElements addObject:imgName];
        }
    }
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _comicElements.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CMImageCell *imgCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"libImgCell" forIndexPath:indexPath];
    imgCell.backgroundColor = [UIColor whiteColor];
    UIImage *curImage = [UIImage imageNamed:[_comicElements objectAtIndex:indexPath.row]];
    imgCell.imgView.image = curImage;
    imgCell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame.png"]];
    return imgCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.parentVC.curImgName = _comicElements[indexPath.row];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

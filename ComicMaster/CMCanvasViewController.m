//
//  CMCanvasViewController.m
//  ComicMaster
//
//  Created by Hang Li on 8/10/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "CMCanvasViewController.h"
#import "CMComicLibViewController.h"
#import "CMComicDAO.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJson.h"
#import "Base64.h"
#import "CMAppDelegate.h"
#import "CMCanvasSettingViewController.h"

static const NSInteger INPUT_ALERTVIEW_TAG = 64;
static const NSInteger TITLE_ALERTVIEW_TAG = 65;
static const NSInteger CONFIRM_ALTERVIEW_TAG = 66;

@interface CMCanvasViewController ()
{
    UIImageView *_curImgView;
    BOOL _isUploading;
    NSMutableArray *_imgStack; // for undo
}

@end

@implementation CMCanvasViewController

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
	_red = 0.0/255.0;
    _green = 0.0/255.0;
    _blue = 0.0/255.0;
    _brush = 10.0;
    _opacity = 1.0;
    _fontSize = 16.0;
    _fontName = @"Arial";
    [_canvasImgView addGestureRecognizer:_doubleTapGestureForTextInput];
    _curImgName = nil;
    if (_curComic != nil) {
        _comicTitle.text = _curComic.title;
        _canvasImgView.image = _curComic.image;
    }
    if (!_canvasImgView.image) {
        _canvasImgView.image = [[UIImage alloc] init];
    }
    _imgStack = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_curImgName != nil) {
        _curImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.curImgName]];
        [_curImgView setUserInteractionEnabled:YES];
        
        UIPanGestureRecognizer *panRcognize=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        panRcognize.delegate=self;
        [panRcognize setEnabled:YES];
        [panRcognize delaysTouchesEnded];
        [panRcognize cancelsTouchesInView];
        [_curImgView addGestureRecognizer:panRcognize];
        
        UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        recognizer.delegate = self;
        [recognizer setNumberOfTapsRequired:1];
        [recognizer requireGestureRecognizerToFail:self.doubleTapGestureForImageConfirm];
        [_curImgView addGestureRecognizer:recognizer];
        //    [recognizer requireGestureRecognizerToFail:monkeyPan];
        //    [recognizer requireGestureRecognizerToFail:bananaPan];
        //    [recognizer requireGestureRecognizerToFail:panRcognize];
        
        
        UIPinchGestureRecognizer *pinchRcognize=[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [pinchRcognize setEnabled:YES];
        [pinchRcognize delaysTouchesEnded];
        [pinchRcognize cancelsTouchesInView];
        pinchRcognize.delegate = self;
        [_curImgView addGestureRecognizer:pinchRcognize];
        
        UIRotationGestureRecognizer *rotationRecognize=[[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
        [rotationRecognize setEnabled:YES];
        [rotationRecognize delaysTouchesEnded];
        [rotationRecognize cancelsTouchesInView];
        rotationRecognize.delegate=self;
        [_curImgView addGestureRecognizer:rotationRecognize];
        
        
        [_curImgView addGestureRecognizer: self.doubleTapGestureForImageConfirm];
        [self.canvasImgView addSubview:_curImgView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.canvasImgView];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.canvasImgView];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [recognizer velocityInView:self.canvasImgView];
        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat slideMult = magnitude / 200;
        
        float slideFactor = 0.1 * slideMult; // Increase for more of a slide
        CGPoint finalPoint = CGPointMake(recognizer.view.center.x + (velocity.x * slideFactor),
                                         recognizer.view.center.y + (velocity.y * slideFactor));
        finalPoint.x = MIN(MAX(finalPoint.x, 0), self.canvasImgView.bounds.size.width);
        finalPoint.y = MIN(MAX(finalPoint.y, 0), self.canvasImgView.bounds.size.height);
        
        [UIView animateWithDuration:slideFactor*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            recognizer.view.center = finalPoint;
        } completion:nil];
        
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    
}


- (void)handleRotate:(UIRotationGestureRecognizer *)recognizer
{
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
}

- (IBAction)penModeSelected:(id)sender
{
    _drawMode = PEN;
}

- (IBAction)textModeSelected:(id)sender
{
    _drawMode = TEXT;
}

- (IBAction)imageModeSelected:(id)sender
{
    _curImgName = nil;
    [self performSegueWithIdentifier:@"showImgLib" sender:self];
    _drawMode = IMAGE;
}

- (IBAction)undo:(id)sender
{
    if (_imgStack.count == 0) {
        return;
    }
    _canvasImgView.image = (UIImage *)[_imgStack lastObject];
    [_imgStack removeLastObject];
}

- (IBAction)handleDoubleTapForTextInput:(UITapGestureRecognizer *)gesture
{
    if (_drawMode != TEXT) {
        return;
    }
    UIAlertView *txtInputAlert = [[UIAlertView alloc] initWithTitle:@"input something funny" message:@"input text" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [txtInputAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    txtInputAlert.tag = INPUT_ALERTVIEW_TAG;
    [txtInputAlert show];
}

- (IBAction)handleDoubleTapForImageConfirm:(id)sender
{
    [_imgStack addObject:_canvasImgView.image];
    UIGraphicsBeginImageContext(self.canvasImgView.frame.size);
    [_canvasImgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    _canvasImgView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [_curImgView removeFromSuperview];
    _curImgView = nil;
    _curImgName = nil;
}

- (IBAction)comicFinished:(id)sender
{
    // prompt user with options
    UIActionSheet *optionSheet = [[UIActionSheet alloc] initWithTitle:@"What to do with your work" delegate:self cancelButtonTitle:@"Wait..." destructiveButtonTitle:@"Discard it" otherButtonTitles:@"Share it", @"Save to local", nil];
    [optionSheet showInView:self.canvasImgView];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_drawMode != PEN && _drawMode != TEXT) {
        return;
    }
    [_imgStack addObject:_canvasImgView.image];
    _mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    _lastPoint = [touch locationInView:self.canvasImgView]; // set last point to current point being touched
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_drawMode != PEN) {
        return;
    }
    _mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:_canvasImgView];
    
    UIGraphicsBeginImageContext(_canvasImgView.frame.size);
    [_canvasImgView.image drawInRect:CGRectMake(0, 0, _canvasImgView.frame.size.width, _canvasImgView.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), _lastPoint.x, _lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), _brush);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), _red / 255.0, _green / 255.0, _blue / 255.0, _opacity);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    _canvasImgView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_drawMode != PEN) {
        return;
    }
    if(!_mouseSwiped) { // user just tapped, draw a point
        UIGraphicsBeginImageContext(_canvasImgView.frame.size);
        [_canvasImgView.image drawInRect:CGRectMake(0, 0, _canvasImgView.frame.size.width, _canvasImgView.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), _brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), _red / 255.0, _green / 255.0, _blue / 255.0, _opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), _lastPoint.x, _lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), _lastPoint.x, _lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        _canvasImgView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIGraphicsBeginImageContext(_canvasImgView.frame.size);
    [_canvasImgView.image drawInRect:CGRectMake(0, 0, _canvasImgView.frame.size.width, _canvasImgView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    _canvasImgView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case INPUT_ALERTVIEW_TAG:
        {
            if (buttonIndex == 1) {
                [_imgStack addObject:_canvasImgView.image];
                NSString *txt = [alertView textFieldAtIndex:0].text;
                UIGraphicsBeginImageContext(_canvasImgView.frame.size);
                CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UIColor colorWithRed:_red / 255.0 green:_green / 255.0 blue:_blue / 255.0 alpha:_opacity].CGColor);
                [_canvasImgView.image drawInRect:CGRectMake(0,0,_canvasImgView.frame.size.width,_canvasImgView.frame.size.height)];
                CGRect rect = CGRectMake(_lastPoint.x, _lastPoint.y, 100, 20);
                UIFont *font = [UIFont fontWithName:_fontName size:_fontSize];
                [txt drawInRect:CGRectIntegral(rect) withFont:font];
                _canvasImgView.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
        }
            break;
        case TITLE_ALERTVIEW_TAG:
        {
            if (buttonIndex == 1) {
                NSString *title = [alertView textFieldAtIndex:0].text;
                [self saveComic:title];
            }
        }
            break;
        case CONFIRM_ALTERVIEW_TAG:
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

- (void)saveComic:(NSString *)title
{
    if (_curComic == nil) { // new comic
        NSLog(@"new comic");
        _curComic = [[CMComic alloc] init];
        _curComic.author = [[CMUser alloc] init];
        _curComic.title = title;
        _curComic.author.userName = ((CMAppDelegate *)[[UIApplication sharedApplication] delegate]).loginUser.userName;
        _curComic.image = _canvasImgView.image;
        _curComic.updateTime = [NSDate date];
        [[CMComicDAO getInstance] addComic:_curComic];
    } else { // update existing comic
        NSLog(@"update comic");
        _curComic.title = title;
        _curComic.author.userName = ((CMAppDelegate *)[[UIApplication sharedApplication] delegate]).loginUser.userName;
        _curComic.image = _canvasImgView.image;
        _curComic.updateTime = [NSDate date];
        [[CMComicDAO getInstance] updateComic:_curComic];
    }
    if (_isUploading) {
        NSLog(@"upload");
        NSData *imgData = UIImagePNGRepresentation(_curComic.image);
        [Base64 initialize];
        NSString *strEncoded = [Base64 encode:imgData];
        // send request
        NSURL *url = [NSURL URLWithString:@"http://localhost/~hang/comicMaster/insertComic.php"];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        request.delegate = self;
        [request setRequestMethod:@"POST"];
        [request addPostValue:_curComic.title forKey:@"title"];
        [request addPostValue:((CMAppDelegate *)[[UIApplication sharedApplication] delegate]).loginUser.userName forKey:@"author"];
        NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
        gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *dateString = [gmtDateFormatter stringFromDate:[NSDate date]];
        [request addPostValue:dateString forKey:@"uploadTime"];
        [request addPostValue:strEncoded forKey:@"image"];
        [request startAsynchronous];
    }
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    [self showAlert:[request responseString] withTag:CONFIRM_ALTERVIEW_TAG];
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    // do sth
}

-(void) showAlert:(NSString *)msg withTag:(NSInteger)tag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.tag = tag;
    [alert show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showImgLib"]) {
        ((CMComicLibViewController *)[segue destinationViewController]).parentVC = self;
    } else if ([[segue identifier] isEqualToString:@"gotoCanvasSetting"]) {
        ((CMCanvasSettingViewController *)[segue destinationViewController]).canvasVC = self;
        ((CMCanvasSettingViewController *)[segue destinationViewController]).red = self.red;
        ((CMCanvasSettingViewController *)[segue destinationViewController]).green = self.green;
        ((CMCanvasSettingViewController *)[segue destinationViewController]).blue = self.blue;
        ((CMCanvasSettingViewController *)[segue destinationViewController]).opacity = self.opacity;
        ((CMCanvasSettingViewController *)[segue destinationViewController]).brush = self.brush;
        ((CMCanvasSettingViewController *)[segue destinationViewController]).fontSize = self.fontSize;
        ((CMCanvasSettingViewController *)[segue destinationViewController]).fontName = self.fontName;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // index needs to be adjusted if actionsheet button is changed
    switch (buttonIndex) {
        case 0: // discard it
            _canvasImgView.image = [[UIImage alloc] init];
            break;
        case 1: // upload to mysql...
        {
            _isUploading = YES;
            UIAlertView *titleInputAlert = [[UIAlertView alloc] initWithTitle:@"Give it a show name" message:@"enter a title" delegate:self cancelButtonTitle:@"Wait..." otherButtonTitles:@"That's it", nil];
            [titleInputAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            titleInputAlert.tag = TITLE_ALERTVIEW_TAG;
            if (_curComic != nil) {
                [titleInputAlert textFieldAtIndex:0].text = _curComic.title;
            }
            [titleInputAlert show];
        }
            break;
        case 2: // save to sqlite
        {
            _isUploading = NO;
            UIAlertView *titleInputAlert = [[UIAlertView alloc] initWithTitle:@"Give it a show name" message:@"enter a title" delegate:self cancelButtonTitle:@"Wait..." otherButtonTitles:@"That's it", nil];
            [titleInputAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            titleInputAlert.tag = TITLE_ALERTVIEW_TAG;
            if (_curComic != nil) {
                [titleInputAlert textFieldAtIndex:0].text = _curComic.title;
            }
            [titleInputAlert show];
        }
            break;
        default:
            break;
    }
}
@end

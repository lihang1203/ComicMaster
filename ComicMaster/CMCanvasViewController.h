//
//  CMCanvasViewController.h
//  ComicMaster
//
//  Created by Hang Li on 8/10/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"
#import "CMComic.h"

typedef enum {
    IMAGE,
    PEN,
    TEXT
} DRAW_MODE;

@interface CMCanvasViewController : UIViewController<UIGestureRecognizerDelegate, UIAlertViewDelegate, ASIHTTPRequestDelegate, UIActionSheetDelegate>
{
    CGPoint _lastPoint;
    BOOL _mouseSwiped;
    DRAW_MODE _drawMode;
}

// draw pen properties
@property (nonatomic) CGFloat red;
@property (nonatomic) CGFloat green;
@property (nonatomic) CGFloat blue;
@property (nonatomic) CGFloat brush;
@property (nonatomic) CGFloat opacity;
@property (nonatomic) CGFloat fontSize;
@property (strong, nonatomic) NSString *fontName;

@property (weak, nonatomic) IBOutlet UIImageView *canvasImgView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapGestureForTextInput;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapGestureForImageConfirm;
@property (strong, nonatomic) NSString *curImgName;
@property (weak, nonatomic) IBOutlet UILabel *comicTitle;
@property (strong, nonatomic) CMComic *curComic;

- (IBAction)penModeSelected:(id)sender;
- (IBAction)textModeSelected:(id)sender;
- (IBAction)imageModeSelected:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)handleDoubleTapForTextInput:(id)sender;
- (IBAction)handleDoubleTapForImageConfirm:(id)sender;
- (IBAction)comicFinished:(id)sender;
- (IBAction)cancel:(id)sender;
@end

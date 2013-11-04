//
//  CMCanvasSettingViewController.h
//  ComicMaster
//
//  Created by Hang Li on 8/19/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMCanvasViewController.h"

@interface CMCanvasSettingViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

// draw pen properties
@property (nonatomic) CGFloat red;
@property (nonatomic) CGFloat green;
@property (nonatomic) CGFloat blue;
@property (nonatomic) CGFloat brush;
@property (nonatomic) CGFloat opacity;
@property (nonatomic) CGFloat fontSize;
@property (strong, nonatomic) NSString *fontName;

@property (weak, nonatomic) IBOutlet UISlider *opacitySlider;
@property (weak, nonatomic) IBOutlet UISlider *brushSlider;
@property (weak, nonatomic) IBOutlet UISlider *fontSizeSlider;
@property (weak, nonatomic) IBOutlet UIPickerView *fontFamilyPicker;
@property (weak, nonatomic) IBOutlet UISlider *colorRSlider;
@property (weak, nonatomic) IBOutlet UISlider *colorGSlider;
@property (weak, nonatomic) IBOutlet UISlider *colorBSlider;
@property (weak, nonatomic) IBOutlet UIImageView *previewImgView;
@property (weak, nonatomic) IBOutlet UILabel *previewLabel;

@property (strong, nonatomic) CMCanvasViewController *canvasVC;

- (IBAction)back:(id)sender;
- (IBAction)sliderChanged:(UISlider *)sender;
@end

//
//  CMCanvasSettingViewController.m
//  ComicMaster
//
//  Created by Hang Li on 8/19/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import "CMCanvasSettingViewController.h"

@interface CMCanvasSettingViewController ()
{
    NSMutableArray *_fontNames;
}
@end

@implementation CMCanvasSettingViewController

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
	// get font names
    _fontNames = [[NSMutableArray alloc] initWithArray:[UIFont familyNames]];
}

- (void)viewDidAppear:(BOOL)animated
{
    _opacitySlider.value = _opacity;
    _brushSlider.value = _brush;
    _fontSizeSlider.value = _fontSize;
    _colorRSlider.value = _red;
    _colorGSlider.value = _green;
    _colorBSlider.value = _blue;
    if (_fontName) {
        for (int i = 0; i < _fontNames.count; ++i) {
            if ([_fontNames[i] isEqualToString:_fontName]) {
                [self.fontFamilyPicker selectRow:i inComponent:0 animated:NO];
                break;
            }
        }
    } else {
        [self.fontFamilyPicker selectRow:0 inComponent:0 animated:NO];
        _fontName = _fontNames[0];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender
{
    self.canvasVC.red = self.red;
    self.canvasVC.green = self.green;
    self.canvasVC.blue = self.blue;
    self.canvasVC.fontName = self.fontName;
    self.canvasVC.fontSize = self.fontSize;
    self.canvasVC.opacity = self.opacity;
    self.canvasVC.brush = self.brush;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sliderChanged:(UISlider *)sender
{
    if (sender == self.brushSlider) {
        self.brush = self.brushSlider.value;
    } else if (sender == self.opacitySlider) {
        self.opacity = self.opacitySlider.value;
    } else if (sender == self.colorRSlider) {
        self.red = self.colorRSlider.value;
    } else if (sender == self.colorGSlider) {
        self.green = self.colorGSlider.value;
    } else if (sender == self.colorBSlider) {
        self.blue = self.colorBSlider.value;
    } else if (sender == self.fontSizeSlider) {
        self.fontSize = self.fontSizeSlider.value;
    }
    UIGraphicsBeginImageContext(self.previewImgView.frame.size);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.brush);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.red / 255.0, self.green / 255.0, self.blue / 255.0, self.opacity);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(),45, 45);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),45, 45);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.previewImgView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.previewLabel.font = [UIFont fontWithName:self.fontName size:self.fontSize];
    self.previewLabel.textColor = [UIColor colorWithRed:self.red / 255.0 green:self.green / 255.0 blue:self.blue / 255.0 alpha:self.opacity];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _fontNames.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _fontNames[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.fontName = _fontNames[row];
    self.previewLabel.font = [UIFont fontWithName:self.fontName size:self.fontSize];
}
@end

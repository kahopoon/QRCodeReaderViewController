/*
 * QRCodeReaderViewController
 *
 * Copyright 2014-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "QRCodeReaderView.h"

@interface QRCodeReaderView ()
@property (nonatomic, strong) UIImageView *offFrameImageView;
@property (nonatomic, strong) UIImageView *onFrameImageView;

@property (nonatomic, strong) NSTimer *showFrameOnTimer;

@end

@implementation QRCodeReaderView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self addFrameView];
    }
    
    return self;
}

#pragma mark - Private Methods

- (void)invalidateTimer {
    if (self.showFrameOnTimer) {
        [self.showFrameOnTimer invalidate];
        self.showFrameOnTimer = nil;
    }
}

- (void)setQRCodeFrameOn {
    [self invalidateTimer];
    
    [UIView animateWithDuration:0.2f
                          delay:0.0
                        options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         [self.offFrameImageView setAlpha:0.0];
                         [self.onFrameImageView setAlpha:1.0];
                     }
                     completion:nil];
    
    self.showFrameOnTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(setQRCodeFrameOff) userInfo:nil repeats:NO];
}

- (void)setQRCodeFrameOff {
    [self invalidateTimer];
    
    [UIView animateWithDuration:0.1f
                          delay:0.0
                        options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         [self.offFrameImageView setAlpha:1.0];
                         [self.onFrameImageView setAlpha:0.0];
                     }
                     completion:nil];
}

- (void)addFrameView {
    UIImage *offFrameImage = [UIImage imageNamed:@"card_qrcode_frame"];
    UIImageView *offFrameImageView = [[UIImageView alloc] initWithImage:offFrameImage];
    [offFrameImageView setBackgroundColor:[UIColor clearColor]];
    [offFrameImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:offFrameImageView];
    _offFrameImageView = offFrameImageView;
    
    UIImage *onFrameImage = [UIImage imageNamed:@"card_qrcode_frame_on"];
    UIImageView *onFrameImageView = [[UIImageView alloc] initWithImage:onFrameImage];
    [onFrameImageView setBackgroundColor:[UIColor clearColor]];
    [onFrameImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [onFrameImageView setAlpha:0.0];
    [self addSubview:onFrameImageView];
    _onFrameImageView = onFrameImageView;
    
    //[self setupAutoLayoutConstraints];
    [self setupAutoLayoutConstraintsWithOrientation];
}

- (void)setupAutoLayoutConstraints:(BOOL)isLandscape
{
//    NSDictionary *views = NSDictionaryOfVariableBindings(_offFrameImageView, _onFrameImageView);
    NSDictionary *views = NSDictionaryOfVariableBindings(_offFrameImageView);
    
    [self removeConstraints:[self constraints]];
    [_offFrameImageView removeConstraints:[_offFrameImageView constraints]];
    [_onFrameImageView removeConstraints:[_onFrameImageView constraints]];

    NSString *offFrameImageViewConstraitFormat =[NSString stringWithFormat:@"%@%@", isLandscape ? @"V":@"H", @":|-50-[_offFrameImageView]-50-|"];
    NSString *onFrameImageViewConstraitFormat =[NSString stringWithFormat:@"%@%@", isLandscape ? @"V":@"H", @":|-50-[_onFrameImageView]-50-|"];
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:offFrameImageViewConstraitFormat options:0 metrics:nil views:views]];
    [self addConstraint:
    [NSLayoutConstraint constraintWithItem:_offFrameImageView
                                 attribute:isLandscape ? NSLayoutAttributeCenterX : NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:isLandscape ? NSLayoutAttributeCenterX : NSLayoutAttributeCenterY
                                multiplier:1
                                  constant:0]];
    [_offFrameImageView addConstraint:
     [NSLayoutConstraint constraintWithItem:_offFrameImageView
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:_offFrameImageView
                                  attribute:NSLayoutAttributeHeight
                                 multiplier:isLandscape ? 0.2 : 1
                                   constant:0]];
    
    views = NSDictionaryOfVariableBindings(_onFrameImageView);
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:onFrameImageViewConstraitFormat options:0 metrics:nil views:views]];
    [self addConstraint:
     [NSLayoutConstraint constraintWithItem:_onFrameImageView
                                  attribute:isLandscape ? NSLayoutAttributeCenterX : NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                  attribute:isLandscape ? NSLayoutAttributeCenterX : NSLayoutAttributeCenterY
                                 multiplier:1
                                   constant:0]];
    [_onFrameImageView addConstraint:
     [NSLayoutConstraint constraintWithItem:_onFrameImageView
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:_onFrameImageView
                                  attribute:NSLayoutAttributeHeight
                                 multiplier:isLandscape ? 0.2 : 1
                                   constant:0]];
}

- (void)setupAutoLayoutConstraintsWithOrientation {
    BOOL deviceOrientationLandscape;
    
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            deviceOrientationLandscape = NO;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            deviceOrientationLandscape = NO;
            break;
        case UIDeviceOrientationLandscapeLeft:
            deviceOrientationLandscape = YES;
            break;
        case UIDeviceOrientationLandscapeRight:
            deviceOrientationLandscape = YES;
            break;
        default:
            if ([self constraints].count == 0) {
                [self setupAutoLayoutConstraints:NO];
            }
            return;
    }
    
    [self setupAutoLayoutConstraints:deviceOrientationLandscape];
}

@end

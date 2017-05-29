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
@property (nonatomic, strong) UIImageView *offFrameImageViewSlave;
@property (nonatomic, strong) UIImageView *onFrameImageView;
@property (nonatomic, strong) UIImageView *onFrameImageViewSlave;

@property (nonatomic, strong) NSTimer *showFrameOnTimer;

@end

@implementation QRCodeReaderView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame defaultOrientation:orientationPortrait dynamicOrientationSupport:NO];
}

- (id)initWithFrame:(CGRect)frame defaultOrientation:(NSString *)defaultOrientation dynamicOrientationSupport:(BOOL)dynamicOrientationSupport {
    if ((self = [super initWithFrame:frame])) {
        self.defaultOrientation         = defaultOrientation;
        self.dynamicOrientationSupport  = dynamicOrientationSupport;
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

- (void)removeFrameView {
    [self.offFrameImageView removeFromSuperview];
    [self.onFrameImageView removeFromSuperview];
    self.offFrameImageView = nil;
    self.onFrameImageView = nil;
}

- (void)addFrameView:(BOOL)isLandscape {
    if (!isLandscape) {
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
    } else {
        //
        UIImage *offFrameImage = [UIImage imageNamed:@"frame_qrcode"];
        UIImageView *offFrameImageView = [[UIImageView alloc] initWithImage:offFrameImage];
        [offFrameImageView setBackgroundColor:[UIColor clearColor]];
        [offFrameImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:offFrameImageView];
        _offFrameImageView = offFrameImageView;
        
        UIImage *offFrameImageSlave = [UIImage imageNamed:@"frame_barcode"];
        UIImageView *offFrameImageViewSlave = [[UIImageView alloc] initWithImage:offFrameImageSlave];
        [offFrameImageViewSlave setBackgroundColor:[UIColor clearColor]];
        [offFrameImageViewSlave setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:offFrameImageViewSlave];
        _offFrameImageViewSlave = offFrameImageViewSlave;
        
        // no onFrameImage for landscape mode
        _onFrameImageView       = offFrameImageView;
        _onFrameImageViewSlave  = offFrameImageViewSlave;
    }
}

- (void)addFrameView {
    if ([self.defaultOrientation isEqualToString:orientationPortrait]) {
        [self addFrameView:NO];
    }
    else if ([self.defaultOrientation isEqualToString:orientationLandscape]) {
        [self addFrameView:YES];
    }
    [self setupAutoLayoutConstraintsWithOrientation];
}

- (void)removeAllConstraits {
    [self removeConstraints:[self constraints]];
    [_offFrameImageView removeConstraints:[_offFrameImageView constraints]];
    [_onFrameImageView removeConstraints:[_onFrameImageView constraints]];
}

- (void)setupAutoLayoutConstraints:(BOOL)isLandscape
{
    [self removeAllConstraits];
//    NSDictionary *views = NSDictionaryOfVariableBindings(_offFrameImageView, _onFrameImageView);
    
    NSString *offFrameImageViewConstraitFormat =[NSString stringWithFormat:@"%@", @"H:|-50-[_offFrameImageView]-50-|"];
    NSString *onFrameImageViewConstraitFormat =[NSString stringWithFormat:@"%@", @"H:|-50-[_onFrameImageView]-50-|"];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_offFrameImageView);
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:offFrameImageViewConstraitFormat options:0 metrics:nil views:views]];
    [self addConstraint:
    [NSLayoutConstraint constraintWithItem:_offFrameImageView
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1
                                  constant:0]];
    [_offFrameImageView addConstraint:
     [NSLayoutConstraint constraintWithItem:_offFrameImageView
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:_offFrameImageView
                                  attribute:NSLayoutAttributeHeight
                                 multiplier:1
                                   constant:0]];
    
    views = NSDictionaryOfVariableBindings(_onFrameImageView);
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:onFrameImageViewConstraitFormat options:0 metrics:nil views:views]];
    [self addConstraint:
     [NSLayoutConstraint constraintWithItem:_onFrameImageView
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1
                                   constant:0]];
    [_onFrameImageView addConstraint:
     [NSLayoutConstraint constraintWithItem:_onFrameImageView
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:_onFrameImageView
                                  attribute:NSLayoutAttributeHeight
                                 multiplier:1
                                   constant:0]];
    
    if (isLandscape) {
        NSString *offFrameImageViewSlaveConstraitFormat =[NSString stringWithFormat:@"%@", @"V:|-50-[_offFrameImageViewSlave]-50-|"];
        NSString *onFrameImageViewSlaveConstraitFormat =[NSString stringWithFormat:@"%@", @"V:|-50-[_onFrameImageViewSlave]-50-|"];
    
        views = NSDictionaryOfVariableBindings(_offFrameImageViewSlave);
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:offFrameImageViewSlaveConstraitFormat options:0 metrics:nil views:views]];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:_offFrameImageViewSlave
                                      attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                      attribute:NSLayoutAttributeCenterX
                                     multiplier:1
                                       constant:0]];
        [_offFrameImageViewSlave addConstraint:
         [NSLayoutConstraint constraintWithItem:_offFrameImageViewSlave
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:_offFrameImageViewSlave
                                      attribute:NSLayoutAttributeHeight
                                     multiplier:115.0/609.0
                                       constant:0]];
        
        views = NSDictionaryOfVariableBindings(_onFrameImageViewSlave);
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:onFrameImageViewSlaveConstraitFormat options:0 metrics:nil views:views]];
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:_onFrameImageViewSlave
                                      attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                      attribute:NSLayoutAttributeCenterX
                                     multiplier:1
                                       constant:0]];
        [_onFrameImageViewSlave addConstraint:
         [NSLayoutConstraint constraintWithItem:_onFrameImageViewSlave
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:_onFrameImageViewSlave
                                      attribute:NSLayoutAttributeHeight
                                     multiplier:115.0/609.0
                                       constant:0]];
    }
}

- (void)setupAutoLayoutConstraintsWithOrientation {
    if ([self constraints].count == 0) {
        BOOL isLandscape = [self.defaultOrientation isEqualToString:orientationLandscape];
        [self setupAutoLayoutConstraints:isLandscape];
        return;
    } else {
        if (self.dynamicOrientationSupport) {
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
                    return;
            }
            [self removeFrameView];
            [self addFrameView:deviceOrientationLandscape];
            [self setupAutoLayoutConstraints:deviceOrientationLandscape];
        }
    }
}

@end

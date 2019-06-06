//
//  CameraDrawView.m
//  IDCardDemo
//
//  Created by linmac on 16-10-15.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import "CameraDrawView.h"
#import <CoreText/CoreText.h>

@implementation CameraDrawView{
    
    CGPoint ldown;
    CGPoint rdown;
    CGPoint lup;
    CGPoint rup;
    CGRect pointRect;
    CGRect textRect;
//    UILabel *label;
//    UIImageView   *scanLine;
    
    NSTimer     *animateTimer;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGRect rect_screen = [[UIScreen mainScreen]bounds];
        CGSize size_screen = rect_screen.size;
        CGFloat width = size_screen.width;
        CGFloat height = size_screen.height;
        _sRect = CGRectMake(45, 100, 230, 230*1.55);
        
        CGFloat hRatio = height/568.0;
        
        if(width == 320&&height==480){ //iphone 4/4s
//            leftBottom = CGPointMake(30, 40);
//            rightBottom = CGPointMake(30, 440);
//            leftTop = CGPointMake(290, 40);
//            rightTop = CGPointMake(290, 440);
            _sRect = CGRectMake(30, 40, 260, 400);
        }
        else { //iphone 5/5s/6/6 plus/6s/6s plus
//            leftBottom = CGPointMake(30*hRatio, 84*hRatio);
//            rightBottom = CGPointMake(30*hRatio, 484*hRatio);
//            leftTop = CGPointMake(290*hRatio, 84*hRatio);
//            rightTop = CGPointMake(290*hRatio, 484*hRatio);
            _sRect = CGRectMake(30*hRatio, 84*hRatio, 260*hRatio, 400*hRatio);
        }

        
        
//        CGFloat fValue = 15.0;
//        if (height == 480)
//        {
//            _sRect = CGRectMake(CGRectGetMinX(_sRect), CGRectGetMinY(_sRect)-44, CGRectGetWidth(_sRect), CGRectGetHeight(_sRect));
//        }else
//        {
//            CGFloat scale = width/320;
//            _sRect = CGRectMake(CGRectGetMinX(_sRect)*scale, CGRectGetMinY(_sRect)*scale, CGRectGetWidth(_sRect)*scale, CGRectGetHeight(_sRect)*scale);
//            fValue = 17.0;
//        }
//
        ldown = CGPointMake(CGRectGetMinX(_sRect), CGRectGetMinY(_sRect));
        lup  = CGPointMake(CGRectGetMaxX(_sRect), CGRectGetMinY(_sRect));
        rdown = CGPointMake(CGRectGetMinX(_sRect), CGRectGetMaxY(_sRect));
        rup = CGPointMake(CGRectGetMaxX(_sRect), CGRectGetMaxY(_sRect));
        self.smallrect = _sRect;
        self.ymzSmallRect = CGRectMake(ldown.x+80, ldown.y-25, rup.x-ldown.x-160,rdown.y-ldown.y+25);
        [self addMask:_sRect];
        
        _label = [[UILabel alloc] init];
        _label.text = @"请将身份证正面置于此区域";//尝试对齐边缘
//        label.text = @"请将银行卡号对准横线";
        _label.textColor = [UIColor whiteColor];
        
        
        //清空背景颜色
        _label.backgroundColor = [UIColor clearColor];
        //设置字体颜色为白色
        _label.textAlignment = NSTextAlignmentCenter;
        //自动折行设置
        _label.lineBreakMode = UILineBreakModeCharacterWrap;
        _label.numberOfLines = 0;
        _label.font = [UIFont systemFontOfSize:18];
        
        _scanLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"scan_line"]];
        _scanLine.frame = CGRectMake(_sRect.origin.x - _sRect.size.height / 14 * 5 +  _sRect.size.height / 21 * 5   , _sRect.origin.y+_sRect.size.height/2 , _sRect.size.height / 7 * 5, 5);
        _scanLine.transform = CGAffineTransformMakeRotation(M_PI_2);
        
        _label.frame = CGRectMake(_sRect.origin.y-10, _sRect.origin.y + _sRect.size.height/2  - 20, _sRect.size.height-20, 40);
        _label.transform = CGAffineTransformMakeRotation(M_PI_2);
//        [self addSubview:scanLine];
        [self addSubview:_label];
        
    }
    return self;
}


- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

/*
 设置四条线的显隐
 */
- (void) setTopHidden:(BOOL)topHidden
{
    if (_topHidden == topHidden) {
        return;
    }
    _topHidden = topHidden;
    [self setNeedsDisplay];
}

- (void) setLeftHidden:(BOOL)leftHidden
{
    if (_leftHidden == leftHidden) {
        return;
    }
    _leftHidden = leftHidden;
    [self setNeedsDisplay];
}

- (void) setBottomHidden:(BOOL)bottomHidden
{
    if (_bottomHidden == bottomHidden) {
        return;
    }
    _bottomHidden = bottomHidden;
    [self setNeedsDisplay];
}

- (void) setRightHidden:(BOOL)rightHidden
{
    if (_rightHidden == rightHidden) {
        return;
    }
    _rightHidden = rightHidden;
    [self setNeedsDisplay];
}

- (void)addMask:(CGRect)rangeRect{
    
    UIView * _maskButton = [[UIView alloc] init];
    [_maskButton setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)];
    [_maskButton setBackgroundColor:[UIColor darkGrayColor]];
    _maskButton.alpha = 0.9;
    [self addSubview:_maskButton];
    
    //create path
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.height)];
    
    // MARK: roundRectanglePath
    [path appendPath:[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(rangeRect.origin.x+5,rangeRect.origin.y+5, rangeRect.size.width-10 , rangeRect.size.height-10) cornerRadius:15] bezierPathByReversingPath]];
    
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    shapeLayer.path = path.CGPath;
    
    [_maskButton.layer setMask:shapeLayer];
    
    }

-(void)setLabelSpace:(UILabel*)label withValue:(NSString*)str withFont:(UIFont*)font wihthCharaterSpace:(NSNumber *)space {
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    
    paraStyle.alignment = NSTextAlignmentLeft;
    
    paraStyle.lineSpacing = 6.0f; //设置行间距
    
    paraStyle.hyphenationFactor = 1.0;
    
    paraStyle.firstLineHeadIndent = 0.0;
    
    paraStyle.paragraphSpacingBefore = 0.0;
    
    paraStyle.headIndent = 0;
    
    paraStyle.tailIndent = 0;
    
    //设置字间距 NSKernAttributeName:@1.5f
    
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:space
                          };
    
    
    
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:str attributes:dic];
    
    label.attributedText = attributeStr;
    
}


#pragma mark -扫描动画

- (void)StartAnimate
{
    if (_ImageVAnimateView == nil) {
        _ImageVAnimateView = [[UIImageView alloc]initWithFrame:CGRectMake(self.smallrect.origin.x +5, self.smallrect.origin.y + 2,self.smallrect.size.width-10, 6) ];
        _ImageVAnimateView.image = [UIImage imageNamed:@"scan_line"];
        [self addSubview:_ImageVAnimateView];
        [self bringSubviewToFront:_ImageVAnimateView];
    }
    _ImageVAnimateView.hidden = NO;
    animateTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(doAnimate) userInfo:nil repeats:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsLayout];
        
    });
    
    
}
- (void)StopAnimate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _ImageVAnimateView.hidden = YES;
        [_ImageVAnimateView removeFromSuperview];
        _ImageVAnimateView = nil;
        [animateTimer invalidate];
        animateTimer = nil;
        [self setNeedsLayout];
        
    });
}
- (void)doAnimate
{
    if (_ImageVAnimateView.frame.origin.y + 10 > (self.smallrect.origin.y + self.smallrect.size.height-5)) {
        _ImageVAnimateView.frame = CGRectMake(self.smallrect.origin.x+5 , self.smallrect.origin.y + 5,self.smallrect.size.width-10, 6) ;
    }
    [UIView animateWithDuration:0.04f animations:^{
        
        //animateView.transform = CGAffineTransformMakeTranslation(idCardRangeRect.origin.x + 5, 0);
        _ImageVAnimateView.transform = CGAffineTransformTranslate(_ImageVAnimateView.transform,0, 5);
        
        
    }];
    
}

@end

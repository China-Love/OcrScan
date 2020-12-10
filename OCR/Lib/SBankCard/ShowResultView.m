//
//  ShowResultView.m
//  IDCardVideo
//
//  Created by mac on 16/9/26.
//  Copyright © 2016年 mac. All rights reserved.
//

//#import "ShowResultView.h"
#import "BCameraViewController.h"
#import "YMIDCardEngine.h"

@implementation ShowResultView

#define SYSTEM_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SYSTEM_WIDTH  [UIScreen mainScreen].bounds.size.width


/*****************************************/
/*
 
            银行卡识别结果显示
*/
/******************************************/
- (instancetype)initWithBankcardImageFrame:(CGRect)rect resultMsg:(NSDictionary *)dic type:(RetType)type
{
    self = [super initWithFrame:CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)];
    
    if (self) {
        self.retType = type;
        self.backgroundColor = [UIColor darkGrayColor];
        
        //显示银行卡照
        _cardImageV = [[UIImageView alloc]initWithFrame:rect];
        _cardImageV.layer.cornerRadius = 15.f;
        _cardImageV.contentMode = UIViewContentModeScaleAspectFit;
        if ([dic objectForKey:[NSNumber numberWithInt:BIDC_IMAGE]]) {
            _cardImageV.image = [dic objectForKey:[NSNumber numberWithInt:BIDC_IMAGE]];
        }
        [self addSubview:_cardImageV];
//        if ([dic objectForKey:[NSNumber numberWithInt:Bank_cardNo_coordinate]]) {
//            NSArray *ArrayCoor = [dic objectForKey:[NSNumber numberWithInt:Bank_cardNo_coordinate]];
//            NSString *CardNum = [dic objectForKey:[NSNumber numberWithInt:Bank_cardNo]];
//            UIImage *image = [self createNewImage:CardNum frames:ArrayCoor Image:[dic objectForKey:[NSNumber numberWithInt:BIDC_IMAGE]] andDic:dic];
//            _cardImageV.image = image;
        
            
//        }
        _cardImageV.transform = CGAffineTransformMakeRotation(M_PI_2);
        
        //增加一层薄膜
        UIView *view = [[UIView alloc]initWithFrame:rect];
        view.backgroundColor = [UIColor darkGrayColor];
        view.alpha = 0.3;
        view.transform = CGAffineTransformMakeRotation(M_PI_2);
        [self addSubview:view];
        
        //返回、闪光灯按钮
        UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMakeBack(0,10,60,60)];
        [backBtn setTitle:@"返回" forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(resultBankBackAction) forControlEvents:UIControlEventTouchUpInside];
//        [backBtn setImage:[UIImage imageNamed:@"Cancel_s"] forState:UIControlStateNormal];
        backBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        
//        backBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
        [self addSubview:backBtn];
        
        
    }
    
    return self;

}

CG_INLINE CGRect
CGRectMakeBack(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
    CGRect rect;
    
    if (SYSTEM_HEIGHT==480) {
        rect.origin.y = y-20;
        rect.origin.x = x;
        rect.size.width = width;
        rect.size.height = height;
    }else{
        rect.origin.x = x * SYSTEM_WIDTH/320;
        rect.origin.y = y * SYSTEM_HEIGHT/568;
        rect.size.width = width * SYSTEM_WIDTH/320;
        rect.size.height = height * SYSTEM_HEIGHT/568;
        
    }
    return rect;
}

- (CGRect)calculateDrawBankCardNumFrame:(CGRect)rect
{
    CGRect newRect = CGRectMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2, rect.size.width, rect.size.height);
    return newRect;


}

- (CGRect)calculateBankCardNumFrame:(CGRect)rect Image:(UIImage *)image
{

    CGRect Nrect;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat lwidth = _cardImageV.frame.size.width;
    CGFloat lheight = _cardImageV.frame.size.height;
    
    CGFloat widthScale = lwidth / width;
    CGFloat heightScale = lheight / height;
    
    CGFloat x = rect.origin.x * widthScale;
  
    
    Nrect = CGRectMake(x + _cardImageV.frame.origin.x, rect.origin.y * heightScale + _cardImageV.frame.origin.y + rect.size.height * heightScale, rect.size.width * widthScale, rect.size.height * heightScale);
    
    return Nrect;


}

- (NSMutableArray *)BankcardNums
{
    if (!_BankcardNums) {
        _BankcardNums = [NSMutableArray array];
    }
    return _BankcardNums;

}
/**
 *  把银行卡号画在图片上
 *
 *  @param Num   银行卡号
 *  @param rect  frame
 *  @param image 银行卡图片
 *
 *  @return 绘制过的图片
 */
- (UIImage *)createNewImage:(NSString *)Nums frames:(NSArray *)ArrayRects Image:(UIImage *)image andDic:(NSDictionary *)Dic
{
  
    CGSize size=CGSizeMake(image.size.width, image.size.height);//画布大小
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    [image drawAtPoint:CGPointMake(0, 0)];
    
    //获得一个位图图形上下文
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    
    CGContextDrawPath(context, kCGPathStroke);
    
    NSArray *ArrayNum = [self stringToSingleString:Nums];
    int i = 0;
    for (NSDictionary *dic in ArrayRects) {
        if (dic) {
//            CGFloat x = [[dic objectForKey:RESULT_COORDINATE_LX] floatValue];
//            CGFloat y = [[dic objectForKey:RESULT_COORDINATE_LY] floatValue];
//            CGFloat width = [[dic objectForKey:RESULT_COORDINATE_WIDTH] floatValue];
//            CGFloat height = [[dic objectForKey:RESULT_COORDINATE_HEIGHT] floatValue];
//            CGRect rect = CGRectMake(x, y,width ,height);
//            CGRect newRect = [self calculateDrawBankCardNumFrame:rect];
//            if (i < ArrayNum.count) {
//                NSString *str = ArrayNum[i];
//                [str drawAtPoint:CGPointMake(newRect.origin.x, 180) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT" size:35],NSForegroundColorAttributeName:[UIColor whiteColor]}];
//                
//                i++;
//            }
        }
    }
    NSString *bankName = [Dic objectForKey:[NSNumber numberWithInt:Bank_bankName]];
    NSString *cardName = [Dic objectForKey:[NSNumber numberWithInt:Bank_cardName]];
    NSString *cardType = [Dic objectForKey:[NSNumber numberWithInt:Bank_cardType]];
    
    [bankName drawAtPoint:CGPointMake(30, image.size.height*0.65) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT" size:30],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [cardName drawAtPoint:CGPointMake(30, image.size.height*0.65+40) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT" size:30],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [cardType drawAtPoint:CGPointMake(30, image.size.height*0.65+80) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT" size:30],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    //画自己想画的内容。。。。。
    
    //返回绘制的新图形
    
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;

}

- (NSArray *)stringToSingleString:(NSString *)string
{
    NSMutableArray *ArrayStr = [NSMutableArray array];
    for (int i = 0 ; i < string.length; i++) {
        NSString *singleStr = [string substringWithRange:NSMakeRange(i, 1)];
        [ArrayStr addObject:singleStr];
    }
    return ArrayStr;

}

- (void)resultBankBackAction
{
    NSInteger buttonIndex = 10;
    if ([self.delegate respondsToSelector:@selector(showResultView:TouchUpInsideButtonIndex:)]) {
        [self.delegate showResultView:self TouchUpInsideButtonIndex:buttonIndex];
    }
}


@end

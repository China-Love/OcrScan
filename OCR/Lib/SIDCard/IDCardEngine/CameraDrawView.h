//
//  CameraDrawView.h
//  IDCardDemo
//
//  Created by linmac on 16-10-15.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraDrawView : UIView

@property (assign, nonatomic) BOOL ymz;
@property (assign, nonatomic) BOOL leftHidden;
@property (assign, nonatomic) BOOL rightHidden;
@property (assign, nonatomic) BOOL topHidden;
@property (assign, nonatomic) BOOL bottomHidden;
@property (assign ,nonatomic) NSInteger smallX;
@property (assign ,nonatomic) CGRect smallrect;
@property (assign, nonatomic) CGRect ymzSmallRect;

@property(nonatomic,strong)UILabel *label;
@property (retain ,nonatomic) UIImageView *headImg; //

@property (assign ,nonatomic) CGRect sRect;  //检测区域


//@property (strong, nonatomic)   UILabel      *LabbankDetail;
//@property (strong, nonatomic)   UIImageView  *ImageVBankLine;
@property (strong, nonatomic)   UIImageView  *ImageVAnimateView;
//@property (nonatomic, assign)   RetType retType;
@property (nonatomic, strong)   UIButton  *FaceShadowView;
@property (nonatomic, strong)   UIButton  *EmbemShadowView;
@property (nonatomic, strong)   UILabel   *labChina;
@property (nonatomic, strong)   UILabel   *labIDCard;

@property (nonatomic, strong) UIImageView   *scanLine;

@property (retain ,nonatomic) UILabel *headLab;
//
//@property (assign, nonatomic)CGRect  CameraTitleRect;


- (void)StartAnimate;


- (void)StopAnimate;

@end

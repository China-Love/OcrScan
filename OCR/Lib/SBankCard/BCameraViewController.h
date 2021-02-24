//
//  CameraViewController.h
//  IDCardDemo
//
//  Created by linmac on 16-10-15.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AudioToolbox/AudioToolbox.h>

#import "AppDelegate.h"
#import "ShowResultView.h"
#import "YMIDCardEngine.h"
#define IDC_HEADIMAGE      -10
#define BIDC_IMAGE          -20

@protocol BCameraVCDelegate;

@interface BCameraViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AppDelegate *appDlg;
    CGRect idCardRangeRect;
}

typedef void(^idInfoMenion)(NSDictionary *infoDic);


@property (nonatomic, retain) CALayer *customLayer;
@property (nonatomic,assign) BOOL isProcessingImage;

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureDeviceInput *captureInput;
@property (strong, nonatomic) AVCaptureStillImageOutput *captureOutput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *preview;
@property(assign,nonatomic) id<BCameraVCDelegate> delegate;

@property (nonatomic, assign) NSInteger exIdCardIndex;

//银行卡识别结果
@property (strong, nonatomic)     NSDictionary *BankCardResult;
//身份证识别结果
@property (strong, nonatomic)     NSMutableArray *IDCardResult;
//识别类型，控制相机的UI
@property (assign, nonatomic)     RetType  rectype;

@property (nonatomic,copy) idInfoMenion idInfoMenion;
@property(strong,nonatomic) YMIDCardEngine *ymIDCardEngine;
@property(strong,nonatomic) UIImage * idCardImage;
@end

@protocol BCameraVCDelegate <NSObject>

-(void)cameraVC:(id)cameraVC cardRecResult:(NSDictionary*)resultDict;

@end

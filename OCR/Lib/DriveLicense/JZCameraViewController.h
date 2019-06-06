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
#import "YMIDCardEngine.h"
@protocol CameraVCDelegate;

@interface JZCameraViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AppDelegate *appDlg;
    CGRect idCardRangeRect;
    
    UIImage *captureImage;
    BOOL  isComplete;
    BOOL  isFocus;
    BOOL  isDisMiss;
    BOOL  isCaptureStillImage;
    BOOL  isFinishCapture;
}


typedef void(^idInfoMenion)(NSDictionary *infoDic);
@property (nonatomic,copy) idInfoMenion idInfoMenion;



@property (nonatomic, retain) CALayer *customLayer;
@property (nonatomic,assign) BOOL isProcessingImage;
@property (nonatomic, assign) NSInteger exIdCardIndex;

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureDeviceInput *captureInput;
@property (strong, nonatomic) AVCaptureStillImageOutput *captureOutput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *preview;
@property(assign,nonatomic) id<CameraVCDelegate> delegate;

@property(strong,nonatomic) YMIDCardEngine *ymIDCardEngine;
@end

@protocol CameraVCDelegate <NSObject>

-(void)cameraVC:(id)cameraVC cardRecResult:(NSDictionary*)resultDict;

@end

//
//  CameraViewController.m
//  IDCardDemo
//
//  Created by linmac on 16-10-15.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import "CameraViewController.h"
#import "CameraDrawView.h"
#import "YMLine.h"
#import "UIViewExt.h"
#import "UKImage.h"
#import <sys/sysctl.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <ImageIO/ImageIO.h>


#import "HPLCardModel.h"
#define NULLString(string) ([string isEqualToString:@""] || (string == nil) || [string isKindOfClass:[NSNull class]])
#define SYSTEM_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SYSTEM_WIDTH  [UIScreen mainScreen].bounds.size.width

@interface CameraViewController ()<UIAlertViewDelegate,BcrResultCallbackDelegate,UIImagePickerControllerDelegate,ShowResultViewDelegate, UINavigationControllerDelegate>{
    
    CameraDrawView *_cameraDrawView;
    BOOL _on;
    
    NSTimer *_timer;
    CAShapeLayer *_maskWithHole;
    AVCaptureDevice *_device;//当前摄像设备
    BOOL _isFoucePixel;
    int _maxCount;
    float _isIOS8AndFoucePixelLensPosition;
    
    NSInteger   bcrResultValue;
    NSInteger   bcrFreeValue;
    
    UIImage * cardImage ;
    HPLCardModel * model;
    BOOL     isReadFont;
    BOOL     isReadBehind;
    BRect cRect;
}

@property (assign, nonatomic) BOOL adjustingFocus;//是否正在对焦
@property (nonatomic,strong) NSMutableDictionary *dataDic;
@property (nonatomic, strong)     ShowResultView *showV;
@end

@implementation CameraViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _maxCount = 4;//最大连续检边次数
    //初始化相机
    [self initialize];
    //创建相机界面控件
    [self createCameraView];
    
   
    [self.ymIDCardEngine setBcrResultCallbackDelegate:self];
    
    self.dataDic = [NSMutableDictionary dictionary];
    
    model=[[HPLCardModel alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    CGRect selfBound = self.view.bounds;
    CGFloat tempWidth = selfBound.size.width;
    CGFloat tempHight = selfBound.size.height;
    selfBound.size.height = tempWidth;
    selfBound.size.width = tempHight-20;  //-20
    
    float idRado = 0.625f;
    //float idRado = 1.5f;
    float scrIdRado = 0.75; //边界范围与整个屏幕比例
    float idCardSize_width;
    float idCardSize_heigt;
    
    if (selfBound.size.height/selfBound.size.width>idRado)
    {
        idCardSize_width = selfBound.size.width*scrIdRado;
        idCardSize_heigt = idCardSize_width*idRado;
    }else
    {
        idCardSize_heigt = selfBound.size.height*scrIdRado;
        idCardSize_width = idCardSize_heigt/idRado;
    }
    
    idCardRangeRect = CGRectMake((selfBound.size.width - idCardSize_width)/2,
                                 (selfBound.size.height - idCardSize_heigt)/2,
                                 idCardSize_width,
                                 idCardSize_heigt);
    
    
    
    if(!_isFoucePixel){//如果不支持相位对焦，开启自定义对焦
        //定时器 开启连续对焦
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.3 target:self selector:@selector(fouceMode) userInfo:nil repeats:YES];
    }
    
    AVCaptureDevice*camDevice =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    int flags = NSKeyValueObservingOptionNew;
    //注册反差对焦通知（5s以下机型）
    [camDevice addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
    if (_isFoucePixel) {
        [camDevice addObserver:self forKeyPath:@"lensPosition" options:flags context:nil];
    }
    [self.session startRunning];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //移除聚焦监听
    AVCaptureDevice*camDevice =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [camDevice removeObserver:self forKeyPath:@"adjustingFocus"];
    if (_isFoucePixel) {
        [camDevice removeObserver:self forKeyPath:@"lensPosition"];
    }
    [self.session stopRunning];
    
}
- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    //关闭定时器
    if(!_isFoucePixel){
        [_timer invalidate];
    }
}

//监听对焦
-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if([keyPath isEqualToString:@"adjustingFocus"]){
        self.adjustingFocus =[[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        //对焦中
    }
    if([keyPath isEqualToString:@"lensPosition"]){
        _isIOS8AndFoucePixelLensPosition =[[change objectForKey:NSKeyValueChangeNewKey] floatValue];
    }
}

//初始化相机
- (void) initialize
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        //判断摄像头授权
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            
            UIAlertView * alt = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"应用相机权限受限,请在设置中启用", nil) message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alt show];
            return;
        }
    }
    //1.创建会话层
    self.session = [[AVCaptureSession alloc] init];
    //设置图片品质
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    //2.创建、配置输入设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices)
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            _device = device;
            self.captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        }
    }
    [self.session addInput:self.captureInput];
    
    ///创建、配置预览输出设备
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    dispatch_queue_t queue;
    queue = dispatch_queue_create("cameraQueue", NULL);
    [captureOutput setSampleBufferDelegate:self queue:queue];
    
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [captureOutput setVideoSettings:videoSettings];
    
    [self.session addOutput:captureOutput];
    
    //3.创建、配置输出
    self.captureOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [self.captureOutput setOutputSettings:outputSettings];
    [self.session addOutput:self.captureOutput];
    
    //判断对焦方式
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        AVCaptureDeviceFormat *deviceFormat = _device.activeFormat;
        if (deviceFormat.autoFocusSystem == AVCaptureAutoFocusSystemPhaseDetection){
            _isFoucePixel = YES;
            _maxCount = 5;//最大连续检边次数
        }
    }
    
    //设置预览
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession: self.session];
    self.preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.preview];
    
    [self.session startRunning];
}

//创建相机界面
- (void)createCameraView{
    
    
    //设置检边视图层
    _cameraDrawView = [[CameraDrawView alloc]initWithFrame:self.view.bounds];;
    _cameraDrawView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_cameraDrawView];
    [_cameraDrawView setNeedsDisplay];
    
    CGPoint center;
    center.x = CGRectGetMidX(_cameraDrawView.sRect);
    center.y = CGRectGetMidY(_cameraDrawView.sRect);
    _cameraDrawView.headImg = [[UIImageView alloc] initWithFrame:CGRectMakeFlash(0, 0, 150, 150)];
    [_cameraDrawView.headImg setImage:[UIImage imageNamed:@"idcard_first_head_5"]];
    _cameraDrawView.headImg.transform = CGAffineTransformMakeRotation(3.14/2);
    _cameraDrawView.headImg.hidden = NO;
    CGPoint cent = center;
    cent.y += _cameraDrawView.sRect.size.height/4*1.2;
    //    cent.x += _cameraDrawView.sRect.size.width/25;
    [_cameraDrawView.headImg setCenter:cent];
    [self.view addSubview:_cameraDrawView.headImg];
    
    //返回、闪光灯按钮
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMakeBack(0,10,60,60)];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    backBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    //    backBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    [self.view addSubview:backBtn];
    [self.view bringSubviewToFront:backBtn];
    
    UIButton *flashBtn = [[UIButton alloc]initWithFrame:CGRectMakeFlash(260,10,60,60)];
    [flashBtn setImage:[UIImage imageNamed:@"flash_on"] forState:UIControlStateNormal];
    [flashBtn setImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateSelected];
    [flashBtn addTarget:self action:@selector(flashBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flashBtn];
    
    
    UIButton *changeBtn;
    changeBtn = [[UIButton alloc]initWithFrame:CGRectMakeFlash(130,SYSTEM_HEIGHT - 80,60,60)];
    [changeBtn setImage:[UIImage imageNamed:@"take_pic_btn"] forState:UIControlStateNormal];
    [changeBtn addTarget:self action:@selector(changeBtn) forControlEvents:UIControlEventTouchUpInside];
    //    [self.view addSubview:changeBtn];
    
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
    singleFingerOne.numberOfTouchesRequired = 1; //手指数
    singleFingerOne.numberOfTapsRequired = 1; //tap次数
    [self.view addGestureRecognizer:singleFingerOne];
    
    
}

//从摄像头缓冲区获取图像
#pragma mark - AVCaptureSession delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    
    
    //获取当前帧数据
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    
    int width = (int)CVPixelBufferGetWidth(imageBuffer);
    int height = (int)CVPixelBufferGetHeight(imageBuffer);
    CGSize imageSize;
    imageSize.width = width;
    imageSize.height = height;
    
    CGRect rect0 = [self getImageSize:imageSize byCardRect:idCardRangeRect];
    NSLog(@"kkk");
    BRect bRect;
    bRect.lx = rect0.origin.x;
    bRect.ly = rect0.origin.y;
    bRect.rx = rect0.origin.x + rect0.size.width;
    bRect.ry = rect0.origin.y + rect0.size.height;
    
    cRect.lx = rect0.origin.x;
    cRect.ly = rect0.origin.y;
    cRect.rx = rect0.size.width+50;
    cRect.ry = rect0.size.height+50;
    
#pragma mark -- begin
    int edge = 0;
    
    cardImage = [self imageFromSampleBuffer:sampleBuffer];
    
    
    if (self.exIdCardIndex == cardType_ID)
    {
        edge = [self.ymIDCardEngine doBcrRecognizeVedioWith_ID:baseAddress andWidth:width andHeight:height andRect:bRect andChannelNumberStr:self.ymIDCardEngine.chNumberStr];
    }
    //    NSLog(@"edge = %d",edge);
    
    if (edge == 100)
    {
        [_session stopRunning];
        NSString *str = @"试用期已过!";
        NSLog(@"试用期已过!");
        bcrFreeValue = 1;
        [self performSelectorOnMainThread:@selector(showCamaraAlert:) withObject:str waitUntilDone:NO];
    }
    if (edge == 200)
    {
        [_session stopRunning];
        NSString *str = @"未授权!";
        NSLog(@"未授权!");
        bcrFreeValue = 1;
        [self performSelectorOnMainThread:@selector(showCamaraAlert:) withObject:str waitUntilDone:NO];
    }
    
    //找边成功
    if (bcrResultValue == 1)
    {
        bcrResultValue = 0;
        //停止取景
        [_session stopRunning];
        [self performSelectorOnMainThread:@selector(perFormDoOcr) withObject:nil waitUntilDone:NO];
        
        
    }
    
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
}

-(void)showCamaraAlert:(NSString*)str
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:str delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

-(void)perFormDoOcr
{
    CGRect rect;
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    switch (self.exIdCardIndex) {
        case cardType_ID:
        {
            resultDict = (NSMutableDictionary*)[self.ymIDCardEngine doBCRWithRect_ID:rect];
        }
            break;
        default:
            break;
    }
    NSLog(@"resultDict=======%@",resultDict);
    [model setValuesForKeysWithDictionary:resultDict];
    
    CGPoint center;
    center.x = CGRectGetMidX(_cameraDrawView.sRect);
    center.y = CGRectGetMidY(_cameraDrawView.sRect);
    CGPoint cent = center;
    if (!NULLString([model.ID_NAME objectForKey:@"value"]) && NULLString([model.ID_VALID objectForKey:@"value"])) {
        
        if (isReadBehind == NO) {
            if (_needBehind == YES) {
                _cameraDrawView.label.text  = @"扫描完成，点击返回";
            }else{
                _cameraDrawView.label.text  = @"请点击屏幕继续识别身份证反面";
            }
            
            isReadFont = YES;
            self.dataDic[@"Name"] = [model.ID_NAME objectForKey:@"value"];
            self.dataDic[@"Sex"] = [model.ID_SEX objectForKey:@"value"];
            self.dataDic[@"Folk"] = [model.ID_FOLK objectForKey:@"value"];
            self.dataDic[@"Birthday"] = [model.ID_BIRT objectForKey:@"value"];
            self.dataDic[@"Address"] = [model.ID_ADDRESS objectForKey:@"value"];
            self.dataDic[@"CardNo"] = [model.ID_NUM objectForKey:@"value"];
            
            
            UIImage* image = [self clipWithImageRect:CGRectMake(cRect.lx, cRect.ly, cRect.rx, cRect.ry) clipImage:cardImage];
            NSData * imageData = UIImageJPEGRepresentation(image, 0.3);
            image = [UIImage imageWithData:imageData];
            self.dataDic[@"img1"] = image;
            
            [_cameraDrawView.headImg setImage:[UIImage imageNamed:@"idcard_last_head_5"]];
            cent.y -= _cameraDrawView.sRect.size.height*1/3;
            cent.x += _cameraDrawView.sRect.size.width/8;
            _cameraDrawView.headImg.hidden = YES;
            [_cameraDrawView.headImg setCenter:cent];
            
        }
        else if (isReadBehind == YES && isReadFont == NO){
            _cameraDrawView.label.text  = @"";
            
            
        }
        if (self.state==ScanStateFront) {
            [self backAction];
        }
    }
    else if (NULLString([model.ID_NAME objectForKey:@"value"]) && !NULLString([model.ID_VALID objectForKey:@"value"])){
        
        if (isReadFont == NO) {
            _cameraDrawView.label.text  = @"不是身份证正面点击屏幕重新扫描";
        }else if (isReadFont == YES && isReadBehind == NO){
            _cameraDrawView.label.text  = @"身份证识别完成";
            isReadBehind = YES;
            self.dataDic[@"有效期"] = [model.ID_VALID objectForKey:@"value"];
            NSArray * arr =  [self.dataDic[@"有效期"] componentsSeparatedByString:@"-"];
            if (arr.count>1) {
                _dataDic[@"star"] = arr[0];
                _dataDic[@"end"] = arr[1];
            }
            //            self.dataDic[@"img2"] = model.ID_IMAGE;
            UIImage* image = [self clipWithImageRect:CGRectMake(cRect.lx, cRect.ly, cRect.rx, cRect.ry) clipImage:cardImage];
            NSData * imageData = UIImageJPEGRepresentation(image, 0.3);
            image = [UIImage imageWithData:imageData];
            self.dataDic[@"img2"] = image;
            _cameraDrawView.headImg.hidden = YES;
            
            [self backAction];
            
        }
        
    }
    
    else{
        _cameraDrawView.label.text  = @"";
        
    }
    
    
}

-(CGRect)getImageSize:(CGSize)imageSize byCardRect:(CGRect)R
{
    NSLog(@"imageSize:%f, %f", imageSize.width, imageSize.height);
    CGRect screenBound  = CGRectMake(0, 0, ([UIScreen mainScreen].bounds.size.width), ([UIScreen mainScreen].bounds.size.height));//self.view.bounds; 紫色
    CGFloat tempWidth = screenBound.size.width;
    CGFloat tempHight = screenBound.size.height;
    screenBound.size.height = tempWidth;
    screenBound.size.width = tempHight;
    
    float screenWidth = screenBound.size.width;//MAX(screenBound.size.width, screenBound.size.height);
    float screenHeight = screenBound.size.height;//MIN(screenBound.size.width, screenBound.size.height);
    float screenRadio = screenHeight/screenWidth;
    
    float imageWidth = imageSize.width;
    float imageHeight = imageSize.height;
    float imageRadio = imageHeight/imageWidth;
    
    CGRect  imageRect = CGRectZero;
    if (screenRadio<imageRadio)
    {
        float radio = screenWidth/imageWidth;
        float offsetheigh = imageSize.height*radio - screenHeight;
        float realHeight = imageHeight*radio;
        imageRect = CGRectMake((R.origin.x)/realHeight*imageSize.height,
                               (R.origin.y+offsetheigh/2)/screenWidth*imageSize.width,
                               R.size.width/realHeight*imageSize.height,
                               R.size.height/screenWidth*imageSize.width);
        
        //设置暂停画面frame
        //        [pauseBgView setFrame:CGRectMake(0, -offsetheigh/2.0f, screenWidth, screenHeight+offsetheigh)];
    }else
    {
        float radio = screenHeight/imageHeight;
        float offsetWidth = imageSize.width*radio - screenWidth;
        float realWith = imageWidth*radio;
        imageRect = CGRectMake((R.origin.x+offsetWidth/2)/screenHeight*imageSize.height,
                               (R.origin.y)/realWith*imageSize.width,
                               R.size.width/screenHeight*imageSize.height,
                               R.size.height/realWith*imageSize.width);
        //设置暂停画面frame
        //        [pauseBgView setFrame:CGRectMake(-offsetWidth/2.0f, 0, screenWidth+offsetWidth, screenHeight)];
    }
    
    return imageRect;
}

//获取摄像头位置
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if (device.position == position)
        {
            return device;
        }
    }
    return nil;
}

//对焦
- (void)fouceMode{
    NSError *error;
    AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
    {
        if ([device lockForConfiguration:&error]) {
            CGPoint cameraPoint = [self.preview captureDevicePointOfInterestForPoint:self.view.center];
            [device setFocusPointOfInterest:cameraPoint];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        } else {
            NSLog(@"Error: %@", error);
        }
    }
}

#pragma mark - ButtonAction
//返回按钮按钮点击事件
- (void)backAction{
    switch (self.exIdCardIndex) {
        case cardType_ID:
            [self.ymIDCardEngine ymClearAll_ID];
            if (self.dataDic.allKeys.count == 0) {
                self.idInfoMenion(nil);
            }else {
                self.idInfoMenion([self.dataDic copy]);
            }
            
            break;
            
        default:
            break;
    }
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.navigationBarHidden = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

//闪光灯按钮点击事件
- (void)flashBtn:(UIButton*)btn{
    btn.selected=!btn.selected;
    AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    if (![device hasTorch]) {
        //        NSLog(@"no torch");
    }else{
        [device lockForConfiguration:nil];
        if (!_on) {
            [device setTorchMode: AVCaptureTorchModeOn];
            _on = YES;
        }
        else
        {
            [device setTorchMode: AVCaptureTorchModeOff];
            _on = NO;
        }
        [device unlockForConfiguration];
    }
}
//图片识别按钮
- (void)changeBtn {
    self.ymIDCardEngine = [[YMIDCardEngine alloc] initWithLanguage:2 andIndex:cardType_ID andChannelNumber:self.chViewNumberStr];
    if (self.ymIDCardEngine.initSuccess)
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            if ([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0) {
                //IOS7,导航栏按钮颜色设置为白色
                [picker.navigationBar setTintColor:[UIColor colorWithRed:0.301 green:0.758 blue:1.000 alpha:1.000]];
            }
            [self presentViewController:picker animated:YES completion:^(void){}];
        }
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"未授权或试用期已过!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    
}

//单击手势
- (void)handleSingleFingerEvent:(UITapGestureRecognizer *)sender {
    if (_needBehind == YES) {
        return;
    }
    
    if (sender.numberOfTapsRequired == 1) {
        if (!NULLString([model.ID_NAME objectForKey:@"value"]) && NULLString([model.ID_VALID objectForKey:@"value"]) && isReadBehind == NO) {
            _cameraDrawView.label.text  = @"请将身份证反面置于此区域";
            _cameraDrawView.headImg.hidden = NO;
            [_session startRunning];
        }
        else if (NULLString([model.ID_NAME objectForKey:@"value"]) && !NULLString([model.ID_VALID objectForKey:@"value"]) && isReadFont ==NO){
            _cameraDrawView.label.text  = @"请将身份证置于此区域";
            [_session startRunning];
        }
        
        
    }
}

- (void)startBackScan{
    isReadFont=YES;
    [self performSelector:@selector(handleSingleFingerEvent) withObject:nil afterDelay:0.2];
}
- (void)handleSingleFingerEvent{
    _cameraDrawView.label.text  = @"请将身份证反面置于此区域";
    CGPoint center;
    center.x = CGRectGetMidX(_cameraDrawView.sRect);
    center.y = CGRectGetMidY(_cameraDrawView.sRect);
    CGPoint cent = center;
    [_cameraDrawView.headImg setImage:[UIImage imageNamed:@"idcard_last_head_5"]];
    cent.y -= _cameraDrawView.sRect.size.height*1/3;
    cent.x += _cameraDrawView.sRect.size.width/8;
    _cameraDrawView.headImg.hidden = YES;
    [_cameraDrawView.headImg setCenter:cent];
    _cameraDrawView.headImg.hidden = NO;
    [_session startRunning];
}

#pragma mark -UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image2;
    NSMutableDictionary *headDict = [NSMutableDictionary dictionary];
    //    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    image2 = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    CGImageRef imRef = [image2 CGImage];
    
    UIImageOrientation orientation = [image2 imageOrientation];
    
    float texWidth = CGImageGetWidth(imRef);
    float texHeight = CGImageGetHeight(imRef);
    
    float imageScale = 1;
    
    if(orientation == UIImageOrientationUp && texWidth < texHeight)
        image2 = [UIImage imageWithCGImage:imRef scale:imageScale orientation: UIImageOrientationLeft];
    else if((orientation == UIImageOrientationUp && texWidth > texHeight) || orientation == UIImageOrientationRight)
        image2 = [UIImage imageWithCGImage:imRef scale:imageScale orientation: UIImageOrientationUp];
    else if(orientation == UIImageOrientationDown)
        image2 = [UIImage imageWithCGImage:imRef scale:imageScale orientation: UIImageOrientationDown];
    else if(orientation == UIImageOrientationLeft)
        image2 = [UIImage imageWithCGImage:imRef scale:imageScale orientation: UIImageOrientationUp];
    
    NSLog(@"originalImage width = %f height = %f",image2.size.width,image2.size.height);
    
    [self.ymIDCardEngine allocBImage:image2];
    
    headDict = (NSMutableDictionary*)[self.ymIDCardEngine doBCRJSON_ID];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (!headDict)
    {
        [self showAlert:@"识别结果为空"];
        return;
    }
    
    
}

//隐藏状态栏
- (UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden{
    
    return YES;
}
-(void)showAlert:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:nil message:(NSString*)sender delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
}

- (NSString *)transTheStringForDictionary:(NSString *)infoString{
    
    infoString =  [infoString stringByReplacingOccurrencesOfString:@"Name" withString:@"\"Name\""];
    infoString =  [infoString stringByReplacingOccurrencesOfString:@"CardNo." withString:@"\"CardNo.\""];
    infoString =  [infoString stringByReplacingOccurrencesOfString:@"Sex" withString:@"\"Sex\""];
    infoString =  [infoString stringByReplacingOccurrencesOfString:@"Birthday" withString:@"\"Birthday\""];
    infoString =  [infoString stringByReplacingOccurrencesOfString:@"Address" withString:@"\"Address\""];
    infoString =  [infoString stringByReplacingOccurrencesOfString:@"Folk" withString:@"\"Folk\""];
    infoString =  [infoString stringByReplacingOccurrencesOfString:@"IssueAuthority" withString:@"\"IssueAuthority\""];
    infoString =  [infoString stringByReplacingOccurrencesOfString:@"ValidPeriod" withString:@"\"ValidPeriod\""];
    return infoString;
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

CG_INLINE CGRect
CGRectMakeFlash(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
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

-(void)bcrResultCallbackWithValue:(NSInteger)value
{
    bcrResultValue = value;
}

- (UIImage *)clipWithImageRect:(CGRect)rect clipImage:(UIImage *)image;

{
    
    CGImageRef imageRef =image.CGImage;
    
    CGImageRef image1 = CGImageCreateWithImageInRect(imageRef,rect);
    
    UIImage* newImage = [[UIImage alloc] initWithCGImage:image1];
    return newImage;
}
@end

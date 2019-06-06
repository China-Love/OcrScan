//
//  IDCardController.m
//  RecordBill
//
//  Created by Who on 2019/6/3.
//  Copyright © 2019 Who. All rights reserved.
//

#import "IDCardController.h"
#import "CameraViewController.h"
#import "OCR.h"
@interface IDCardController ()
@property (nonatomic,retain) UIImageView * frontImgView,*backImgView;
@property (nonatomic,retain) UILabel * resultLab;
@property (nonatomic,retain) NSMutableDictionary * muInfoDic;
@end

@implementation IDCardController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"IDCardScan";
    self.view.backgroundColor=[UIColor whiteColor];
    
    
    [self ShowResultUI];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"customerScan"] style:UIBarButtonItemStylePlain target:self action:@selector(IdCardScan)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
   self.muInfoDic=[NSMutableDictionary new];
}

- (void)IdCardScan{
    [self IdCardScan:ScanStateAll];
}

- (void)backViewBtnClick{
    [self IdCardScan:ScanStateBack];
}

- (void)frontViewBtnClick{
    [self IdCardScan:ScanStateFront];
}

- (void)IdCardScan:(ScanState)scanState{
     __weak typeof(self) Self = self;
    CameraViewController *cameraVC = [[CameraViewController alloc] init];
  
    cameraVC.idInfoMenion = ^(NSDictionary *infoDic) {
        if (infoDic[@"img1"] && infoDic[@"img2"]) {
            NSMutableDictionary * Dic=[[NSMutableDictionary alloc]initWithDictionary:infoDic];
            Self.frontImgView.image=Dic[@"img1"];
            [Dic removeObjectForKey:@"img1"];
            Self.backImgView.image=Dic[@"img2"];
            [Dic removeObjectForKey:@"img2"];
            [Self.muInfoDic addEntriesFromDictionary:Dic];
            NSError *parseError = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:Self.muInfoDic options:NSJSONWritingPrettyPrinted error:&parseError];
            Self.resultLab.text= [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        else if (infoDic[@"img1"]) {
            NSMutableDictionary * Dic=[[NSMutableDictionary alloc]initWithDictionary:infoDic];
            Self.frontImgView.image=Dic[@"img1"];
            [Dic removeObjectForKey:@"img1"];
            [Self.muInfoDic addEntriesFromDictionary:Dic];
            NSError *parseError = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:Self.muInfoDic options:NSJSONWritingPrettyPrinted error:&parseError];
            Self.resultLab.text= [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        else if (infoDic[@"img2"]) {
            NSMutableDictionary * Dic=[[NSMutableDictionary alloc]initWithDictionary:infoDic];
            Self.backImgView.image=Dic[@"img2"];
            [Dic removeObjectForKey:@"img2"];
            [Self.muInfoDic addEntriesFromDictionary:Dic];
            NSError *parseError = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:Self.muInfoDic options:NSJSONWritingPrettyPrinted error:&parseError];
            Self.resultLab.text= [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }

    };
    
    cameraVC.ymIDCardEngine =[OCR initializationWithLanguage:2 andIndex:cardType_ID];
    
    
    if (cameraVC.ymIDCardEngine.initSuccess)
    {
        cameraVC.exIdCardIndex = cardType_ID;
        cameraVC.state=scanState;
        [self.navigationController pushViewController:cameraVC animated:YES];
        
        if (scanState==ScanStateBack) {
            [cameraVC startBackScan];
        }
    }else{
        NSLog(@"未授权或试用期已过!");
    }
  
}






























- (void)ShowResultUI{
    
    
    UILabel *frontLabel = [[UILabel alloc] init];
    frontLabel.frame = CGRectMake(0,235.5,self.view.frame.size.width,11.5);
    frontLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:frontLabel];
    
    NSMutableAttributedString *frontLabelstring = [[NSMutableAttributedString alloc] initWithString:@"点击扫描人像面" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Thonburi" size: 12],NSForegroundColorAttributeName: [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]}];
    
    [frontLabelstring addAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0]} range:NSMakeRange(4, 3)];
    
    frontLabel.attributedText = frontLabelstring;
    
    UIImageView * frontBgImgView=[[UIImageView alloc]init];
    frontBgImgView.image=[UIImage imageNamed:@"cameraBg"];
    frontBgImgView.backgroundColor=[UIColor colorWithRed:239/255.0 green:246/255.0 blue:255/255.0 alpha:1];
    frontBgImgView.frame=CGRectMake(self.view.frame.size.width/2-90,100,180,120);
    [self.view addSubview:frontBgImgView];
    
    UIImageView * frontImgView=[[UIImageView alloc]init];
    frontImgView.image=[UIImage imageNamed:@"Idcard"];
    frontImgView.frame=CGRectMake(self.view.frame.size.width/2-85,105,170,110);
    [self.view addSubview:frontImgView];
    self.frontImgView=frontImgView;
    
    UIImageView * frontCameraView=[[UIImageView alloc]init];
    frontCameraView.image=[UIImage imageNamed:@"camera"];
    frontCameraView.frame=CGRectMake(CGRectGetMidX(frontBgImgView.frame)-15,CGRectGetMidY(frontBgImgView.frame)-13,30,26);
    [self.view addSubview:frontCameraView];
    
    UIButton *frontBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    frontBtn.frame=frontBgImgView.frame;
    [frontBtn addTarget:self action:@selector(frontViewBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:frontBtn];
    
    
    
    UILabel *backLabel = [[UILabel alloc] init];
    backLabel.frame = CGRectMake(0,400,self.view.frame.size.width,11.5);
    backLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:backLabel];
    
    NSMutableAttributedString *backLabelstring = [[NSMutableAttributedString alloc] initWithString:@"点击扫描国徽面" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Thonburi" size: 12],NSForegroundColorAttributeName: [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]}];
    
    [backLabelstring addAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0]} range:NSMakeRange(4, 3)];
    
    backLabel.attributedText = backLabelstring;
    
    UIImageView * backBgImgView=[[UIImageView alloc]init];
    backBgImgView.image=[UIImage imageNamed:@"cameraBg"];
    backBgImgView.backgroundColor=[UIColor colorWithRed:239/255.0 green:246/255.0 blue:255/255.0 alpha:1];
    backBgImgView.frame=CGRectMake(self.view.frame.size.width/2-90,267,180,120);
    [self.view addSubview:backBgImgView];
    
    UIImageView * backImgView=[[UIImageView alloc]init];
    backImgView.image=[UIImage imageNamed:@"IdCardBack"];
    backImgView.frame=CGRectMake(self.view.frame.size.width/2-85,272,170,110);
    [self.view addSubview:backImgView];
    self.backImgView=backImgView;
    
    UIImageView * backCameraView=[[UIImageView alloc]init];
    backCameraView.image=[UIImage imageNamed:@"camera"];
    backCameraView.frame=CGRectMake(CGRectGetMidX(backBgImgView.frame)-15,CGRectGetMidY(backBgImgView.frame)-13,30,26);
    [self.view addSubview:backCameraView];
    
    UIButton *backBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame=backBgImgView.frame;
    [backBtn addTarget:self action:@selector(backViewBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UILabel * resultLab=[[UILabel alloc]initWithFrame:CGRectMake(10, 400, self.view.frame.size.width-20, 250)];
    resultLab.font=[UIFont boldSystemFontOfSize:14];
    resultLab.numberOfLines=0;
    [self.view addSubview:resultLab];
    self.resultLab=resultLab;
}

@end

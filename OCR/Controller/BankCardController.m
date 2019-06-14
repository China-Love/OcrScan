//
//  BankCardController.m
//  RecordBill
//
//  Created by Who on 2019/6/3.
//  Copyright © 2019 Who. All rights reserved.
//

#import "BankCardController.h"
#import "BCameraViewController.h"
#import "OCR.h"

@interface BankCardController ()
@property (nonatomic,retain) UIImageView * frontImgView,*frontBgImgView;
@property (nonatomic,retain) UILabel * resultLab;
@end

@implementation BankCardController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"BankCardScan";
    self.view.backgroundColor=[UIColor whiteColor];
    [self ShowResultUI];

    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"customerScan"] style:UIBarButtonItemStylePlain target:self action:@selector(bankScan)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    UILabel * noticeLab =[[UILabel alloc]init];
    noticeLab.font=[UIFont boldSystemFontOfSize:14];
    noticeLab.textColor=[UIColor colorWithRed:227/255.0 green:23/255.0 blue:13/255.0 alpha:1];
    noticeLab.textAlignment=2;
    noticeLab.frame=CGRectMake(0, self.navigationController.navigationBar.frame.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height, self.view.frame.size.width-20, 50);
    noticeLab.text=@"点击右上角扫描按钮→↑";
    [self.view addSubview:noticeLab];
}
- (void)bankScan{
    
    __weak typeof(self) Self = self;
    BCameraViewController *cameraVC = [[BCameraViewController alloc] init];
    
    cameraVC.idInfoMenion = ^(NSDictionary *infoDic) {
        if (infoDic) {
            Self.frontBgImgView.hidden=NO;
            NSMutableDictionary * Dic=[[NSMutableDictionary alloc]initWithDictionary:infoDic];
            Self.frontImgView.image=Dic[@"img"];
            [Dic removeObjectForKey:@"img"];
            
            NSError *parseError = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:Dic options:NSJSONWritingPrettyPrinted error:&parseError];
            Self.resultLab.text= [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    };
    
    cameraVC.rectype = RetBankCardVideo;

    cameraVC.ymIDCardEngine = [OCR initializationWithLanguage:2 andIndex:cardType_Bank];
  
    if (cameraVC.ymIDCardEngine.initSuccess) {
        cameraVC.exIdCardIndex = cardType_Bank;
        [self.navigationController pushViewController:cameraVC animated:YES];
        
    }else{
        NSLog(@"未授权或试用期已过!");
    }

}








- (void)ShowResultUI{
 

 


    UIImageView * frontBgImgView=[[UIImageView alloc]init];
    frontBgImgView.image=[UIImage imageNamed:@"cameraBg"];
    frontBgImgView.frame= CGRectMake(self.view.frame.size.width/2-90,150,180,120);
    [self.view addSubview:frontBgImgView];
    self.frontBgImgView=frontBgImgView;
    self.frontBgImgView.hidden=YES;
    
    UIImageView * frontImgView=[[UIImageView alloc]init];
    frontImgView.frame= CGRectMake(self.view.frame.size.width/2-85,155,170,110);
    [self.view addSubview:frontImgView];
    self.frontImgView=frontImgView;
    
    UILabel * resultLab=[[UILabel alloc]initWithFrame:CGRectMake(10, 250, self.view.frame.size.width-20, 300)];
    resultLab.font=[UIFont boldSystemFontOfSize:14];
    resultLab.numberOfLines=0;
    [self.view addSubview:resultLab];
    self.resultLab=resultLab;
    
    [OCR StartInit]; // 非demo不需要在此注册再次初始化

}

@end

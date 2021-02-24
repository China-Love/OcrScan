//
//  ViewController.m
//  OCR
//
//  Created by Who on 2019/6/3.
//

#import "ViewController.h"

#import "IDCardController.h"
#import "DrivingLicenceController.h"
#import "BankCardController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title=@"OCR";
    [self SetUI];
    
}

- (void)SetUI{
    
    UIButton * idScanBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    idScanBtn.layer.borderColor=[UIColor grayColor].CGColor;
    idScanBtn.layer.borderWidth=1;
    idScanBtn.layer.cornerRadius=5;
    idScanBtn.frame=CGRectMake(50, 200, self.view.frame.size.width-100, 50);
    [idScanBtn setTitle:@"身份证扫描" forState:0];
    [idScanBtn setTitleColor:[UIColor grayColor] forState:0];
    [idScanBtn addTarget:self action:@selector(IdCardScan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:idScanBtn];
    
    UIButton * bankScanBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    bankScanBtn.layer.borderColor=[UIColor grayColor].CGColor;
    bankScanBtn.layer.borderWidth=1;
    bankScanBtn.layer.cornerRadius=5;
    bankScanBtn.frame=CGRectMake(50, 300, self.view.frame.size.width-100, 50);
    [bankScanBtn setTitle:@"银行卡扫描" forState:0];
    [bankScanBtn setTitleColor:[UIColor grayColor] forState:0];
    [bankScanBtn addTarget:self action:@selector(bankScan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bankScanBtn];
    
    
    UIButton * drivingLicenceScanBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    drivingLicenceScanBtn.layer.borderColor=[UIColor grayColor].CGColor;
    drivingLicenceScanBtn.layer.borderWidth=1;
    drivingLicenceScanBtn.layer.cornerRadius=5;
    drivingLicenceScanBtn.frame=CGRectMake(50, 400, self.view.frame.size.width-100, 50);
    [drivingLicenceScanBtn setTitle:@"驾驶证扫描" forState:0];
    [drivingLicenceScanBtn setTitleColor:[UIColor grayColor] forState:0];
    [drivingLicenceScanBtn addTarget:self action:@selector(drivingLicenceScan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:drivingLicenceScanBtn];
    
    
    UILabel * noticeLab =[[UILabel alloc]init];
    noticeLab.font=[UIFont boldSystemFontOfSize:14];
    noticeLab.textColor=[UIColor colorWithRed:128/255.0 green:138/255.0 blue:135/255.0 alpha:1];
    noticeLab.textAlignment=1;
    noticeLab.frame=CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50);
    noticeLab.text=@"如有需求请联系QQ 820649600";
    [self.view addSubview:noticeLab];
}

- (void)IdCardScan{
    IDCardController *VC=[[IDCardController alloc]init];
    [self.navigationController pushViewController:VC animated:YES];
}


- (void)bankScan{
    BankCardController *VC =[[BankCardController alloc]init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)drivingLicenceScan{
    DrivingLicenceController *VC =[[DrivingLicenceController alloc]init];
    [self.navigationController pushViewController:VC animated:YES];
}



@end

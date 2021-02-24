//
//  HPLCardModel.h
//  BankCardVideo
//
//  Created by 王宝明 on 2017/7/4.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPLCardModel : NSObject

//@property (nonatomic,assign) int type; //1:正面  2:反面
@property (nonatomic,strong) NSDictionary *ID_NUM; //身份证号
@property (nonatomic,strong) NSDictionary *ID_NAME; //姓名
@property (nonatomic,strong) NSDictionary *ID_BIRT;
@property (nonatomic,strong) NSDictionary *ID_SEX; //性别
@property (nonatomic,strong) NSDictionary *ID_FOLK; //民族
@property (nonatomic,strong) NSDictionary *ID_ADDRESS; //地址
@property (nonatomic,strong) NSDictionary *ID_ISSUE; //签发机关
@property (nonatomic,strong) NSDictionary *ID_VALID; //有效期
@property (nonatomic, strong) UIImage         *ID_HEADIMAGE;

@property (nonatomic, strong) UIImage         *ID_IMAGE;//



@property (nonatomic, strong) NSString         *JZ_ADDRESS;//地址
@property (nonatomic, strong) NSString         *JZ_BIRTHDAY;//出生日期
@property (nonatomic, strong) NSString         *JZ_CARDNO;//正号
@property (nonatomic, strong) NSString         *JZ_COUNTRY;//国籍
@property (nonatomic, strong) NSString         *JZ_DRIVING_TYPE;//类型
@property (nonatomic, strong) UIImage         *JZ_IDIMAGE;//头像
@property (nonatomic, strong) NSString         *JZ_ISSUE_DATE;//领证日期
@property (nonatomic, strong) NSString         *JZ_NAME;//名字
@property (nonatomic, strong) NSString         *JZ_REGISTER_DATE;//期限
@property (nonatomic, strong) NSString         *JZ_SEX;//性别
@property (nonatomic, strong) NSString         *JZ_VALID_PERIOD;



@end

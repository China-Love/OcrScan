//
//  OCREngine.h
//  IDCardScanDemo
//
//  Created by  on 14-04-16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
//  若有疑问请联系 QQ 820649600

#import <Foundation/Foundation.h>
#import "libCommon.h"
#import <UIKit/UIKit.h>
#define RES_XSSTR  @"XSSTR"
#define RES_JZSTR  @"JZSTR"
#define RES_CPSTR  @"CPSTR"
#define RES_IDSTR  @"IDSTR"

//身份证
#define RESID_NAME          @"ID_NAME"          //姓名
#define RESID_SEX           @"ID_SEX"           //性别
#define RESID_FOLK          @"ID_FOLK"          //民族
#define RESID_BIRT          @"ID_BIRT"          //出生日期
#define RESID_ADDRESS       @"ID_ADDRESS"       //住址
#define RESID_NUM           @"ID_NUM"           //公民身份号码
#define RESID_ISSUE         @"ID_ISSUE"         //签发机关
#define RESID_VALID         @"ID_VALID"         //有效期限
#define RESID_IMAGE         @"ID_IMAGE"         //证件图片
#define RESID_HEADIMAGE     @"ID_HEADIMAGE"     //证件头像图片

//行驶证
#define RESXS_NAME          @"XS_NAME"          //所有人
#define RESXS_CARDNO        @"XS_CARDNO"        //号牌号码
#define RESXS_ADDRESS       @"XS_ADDRESS"       //住址
#define RESXS_VEHICLETYPE   @"XS_VEHICLETYPE"   //车辆类型
#define RESXS_USECHARACTE   @"XS_USECHARACTE"   //使用性质
#define RESXS_MODEL         @"XS_MODEL"         //品牌型号
#define RESXS_VIN           @"XS_VIN"           //车辆识别代号
#define RESXS_ENGINEPN      @"XS_ENGINEPN"      //发动机号码
#define RESXS_REGISTERDATE  @"XS_REGISTERDATE"  //注册日期
#define RESXS_ISSUEDATE     @"XS_ISSUEDATE"     //发证日期
#define RESXS_IDIMAGE       @"XS_IDIMAGE"       //证件图片

//驾照
#define RESJZ_NAME          @"JZ_NAME"          //姓名
#define RESJZ_CARDNO        @"JZ_CARDNO"        //证号
#define RESJZ_SEX           @"JZ_SEX"           //性别
#define RESJZ_BIRTHDAY      @"JZ_BIRTHDAY"      //出生日期
#define RESJZ_ADDRESS       @"JZ_ADDRESS"       //住址
#define RESJZ_ISSUE_DATE    @"JZ_ISSUE_DATE"    //初次领证日期
#define RESJZ_VALID_PERIOD  @"JZ_VALID_PERIOD"  //有效期限
#define RESJZ_COUNTRY       @"JZ_COUNTRY"       //国籍
#define RESJZ_DRIVING_TYPE  @"JZ_DRIVING_TYPE"  //准驾车型
#define RESJZ_REGISTER_DATE @"JZ_REGISTER_DATE" //有效起始日期
#define RESJZ_IDIMAGE       @"JZ_IDIMAGE"       //证件图片

//车牌
#define RESCP_NAME          @"JZ_NAME"          //姓名
#define RESCP_CARDNO        @"JZ_CARDNO"        //证号
#define RESCP_SEX           @"JZ_SEX"           //性别
#define RESCP_BIRTHDAY      @"JZ_BIRTHDAY"      //出生日期

//车牌
#define RESCP_IDIMAGE       @"CP_IDIMAGE"       //证件图片

//vin码
#define RESVIN_RESULT       @"VIN_RESULT"    //识别结果
#define RESVIN_IDIMAGE      @"VIN_IDIMAGE"   //整张图片
#define RESVIN_HEADIMAGE    @"VIN_HEADIMAGE" //VIN图片

@protocol BCRProgressCallBackDelegate;

@protocol BcrResultCallbackDelegate <NSObject>
@required -(void)bcrResultCallbackWithValue:(NSInteger)value;
@end

@protocol BcrFreeCallbackDelegate <NSObject>
@required -(void)bcrFreeCallbackWithFreeValue:(NSInteger)freeValue;
@end

@interface YMIDCardEngine : NSObject
{
    NSInteger       progress;
    UIImage         *idCardImage;
    NSInteger       cardIndex;
    UIImage         *headImage;
}

typedef enum
{
    Bank_NON,                  //non
    Bank_cardNo,              //银行卡卡号
    Bank_bankName,            //银行名称
    Bank_cardName,            //银行卡名称
    Bank_cardType,            //银行卡类型
    Bank_MEMO
} BankCard;

typedef enum
{
    ID_NON,                  //non
    ID_cardNo,              //
} IDCard;

typedef enum
{
    cardType_Bank,            //银行卡
    cardType_ID,              //身份证
    cardType_JZ,              //驾照
    cardType_XS,              //行驶证
    cardType_CP,              //车牌
    cardType_VIN,             //VIN
} CardType;

@property (nonatomic, assign) NSInteger ocrLanguage;

//初始化是否成功
@property (nonatomic) BOOL     initSuccess;

//@property(nonatomic,assign)NSInteger bcrIndex;

@property(nonatomic, assign) NSString *chNumberStr;

/**
 初始化引擎
 @param   language：识别语言   默认传2
 @param   channelNumberStr：客户授权渠道号
 @return
 */
- (id)initWithLanguage:(NSInteger)language andIndex:(NSInteger)index andChannelNumber:(NSString*)channelNumberStr;

/**
 拍照或者导入申请图片
 @param   image：图片
 @return  0：失败
 1：成功
 */
- (BOOL)allocBImage:(UIImage *)image;

/**
 视频识别申请图片
 @param   image：图片
 @return  0：失败
 1：成功
 */
- (BOOL)allocBImageVideo:(UIImage*)image;

/**
 身份证拍照或者导入识别
 @param
 @return  NSDictionary：身份证拍照或者导入识别结果
          JSON格式
 */
- (NSDictionary *)doBCRJSON_ID;

/**
 驾照拍照或者导入识别
 @param
 @return  NSDictionary：驾照拍照或者导入识别结果
 */
- (NSDictionary *)doBCR_JZ;

/**
 银行卡视频识别
 @param width    图像宽度
 @param height   图像高度
 @param pRect    视频图像四个点的位置信息
 
 @return  100：试用期已过
 200：未授权
 0：表示处理事变， 1~16：表示是否存在四条边框信息
 */
-(int)doBcrRecognizeVedioWithBuffer:(UInt8 *)buffer andWidth:(int)width andHeight:(int)height andRect:(BRect)pRect andChannelNumberStr:(NSString *)channelNumberStr;

/**
 身份证视频识别找边
 @param width    图像宽度
 @param height   图像高度
 @param pRect    视频图像四个点的位置信息
 
 @return  100：试用期已过
 200：未授权
 0：表示处理事变， 1~16：表示是否存在四条边框信息
 */
-(int)doBcrRecognizeVedioWith_ID:(UInt8 *)buffer andWidth:(int)width andHeight:(int)height andRect:(BRect)pRect andChannelNumberStr:(NSString *)channelNumberStr;

/**
 驾照视频识别找边
 @param width    图像宽度
 @param height   图像高度
 @param pRect    视频图像四个点的位置信息
 
 @return  100：试用期已过
 200：未授权
 0：表示处理事变， 1~16：表示是否存在四条边框信息
 */
-(int)doBcrRecognizeVedioWith_JZ:(UInt8 *)buffer andWidth:(int)width andHeight:(int)height andRect:(BRect)pRect andChannelNumberStr:(NSString *)channelNumberStr;

/**
 身份证视频识别结果
 @param   rect：预留参数
 @return  NSDictionary：识别结果为字典格式

 */
- (NSDictionary *)doBCRWithRect_ID:(CGRect)rect;

/**
 驾照视频识别结果
 @param   rect：预留参数
 @return  NSDictionary：识别结果为字典格式

 */
- (NSDictionary *)doBCRWithRect_JZ:(CGRect)rect;

/**
 银行卡视频识别结果
 @param   rect：预留参数
 @return  NSDictionary：识别结果为字典格式
 
 */

- (NSDictionary *)doBCRWithRect:(CGRect)rect;

/**
 视频识别结果回调
 @param   delegate：代理
 @return
 
 */
-(void)setBcrResultCallbackDelegate:(id)delegate;

/**
 身份证视频识别取消释放
 @param
 @return
 
 */
- (void)ymClearAll_ID;

/**
 驾照视频识别取消释放
 @param
 @return
 
 */
- (void)ymClearAll_JZ;

@end



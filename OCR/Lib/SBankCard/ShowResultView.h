//
//  ShowResultView.h
//  IDCardVideo
//
//  Created by mac on 16/9/26.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 识别结果类型
 */
typedef enum
{
    RetIdCardVideoFront,    //身份证视频拍照正面
    RetIdCardVideoBack,     //身份证视频拍照背面
    RetIdCardPhotoFront,   //拍照识别正面
    RetIdCardPhotoBack,    //拍照识别背面
    RetBankCardVideo,       //银行卡识别
    
}RetType;

@class ShowResultView;
@protocol ShowResultViewDelegate<NSObject>
@optional
/**
 *  传递在这个view中按钮被按下的信息
 *
 *  @param showresultV
 *  @param buttonIndex 按键号 1：重新拍摄，或者重新扫描  2：修改信息    3：进入下一步
 */
- (void)showResultView:(ShowResultView *)showresultV TouchUpInsideButtonIndex:(NSInteger)buttonIndex;

@end


@interface ShowResultView : UIView
//显示识别结果类型
@property (nonatomic,  assign)   RetType retType;
//证件照
@property (nonatomic, strong)    UIImageView   *cardImageV;
//重新拍照
@property (nonatomic, strong)    UIButton     *btnReRec;
//修改信息
@property (nonatomic, strong)    UIButton     *btnModifyMsg;

@property (nonatomic,strong)     UIButton     *btnNext;
//提示信息
@property (nonatomic, strong)    UILabel      *labTitle;
//名字
@property (nonatomic, strong)    UILabel      *labName;
//地址
@property (nonatomic, strong)    UILabel      *labAddress;
//身份证号
@property (nonatomic, strong)    UILabel      *labIdcardNum;
//有效日期
@property (nonatomic, strong)    UILabel      *labValidDate;
//签发机关
@property (nonatomic, strong)    UILabel      *labIssuingAuthority;
//银行卡号
@property (nonatomic, strong)    NSMutableArray      *BankcardNums;
//代理
@property (nonatomic, weak)     id<ShowResultViewDelegate>   delegate;

@property (nonatomic, strong)    UIButton    *BtnBack;

- (instancetype)initWithBankcardImageFrame:(CGRect)rect resultMsg:(NSDictionary *)dic type:(RetType)type;
@end

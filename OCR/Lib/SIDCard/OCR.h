//
//  OCR.h
//  OCR
//
//  Created by Who on 2019/6/4.
//

#import "YMIDCardEngine.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface OCR : NSObject
///**
// 初始化引擎
// @param   language：识别语言   默认传2
// @param   index:
                    //cardType_Bank,            //银行卡
                    //cardType_ID,              //身份证
                    //cardType_JZ,              //驾照
                    //cardType_XS,              //行驶证
                    //cardType_CP,              //车牌
                    //cardType_VIN,             //VIN
// @return 初始化的对象
// */
+(YMIDCardEngine*)initializationWithLanguage:(NSInteger)language andIndex:(NSInteger)index;

+(void)StartInit;
@end

NS_ASSUME_NONNULL_END

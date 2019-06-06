//
//  NSAttributedString+CC.h
//  BankCardVideo
//
//  Created by mac on 16/9/24.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<UIKit/UIKit.h>

@interface NSAttributedString (CC)

+ (instancetype)attributedStringSourceString:(NSString *)sourceStr sourceColor:(UIColor *)sourceColor subString:(NSString *)substring substringColor:(UIColor *)substringColor;

@end

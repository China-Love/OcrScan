//
//  NSAttributedString+CC.m
//  BankCardVideo
//
//  Created by mac on 16/9/24.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "NSAttributedString+CC.h"

@implementation NSAttributedString (CC)


+ (instancetype)attributedStringSourceString:(NSString *)sourceStr sourceColor:(UIColor *)sourceColor subString:(NSString *)substring substringColor:(UIColor *)substringColor
{

     NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:sourceStr];
    NSRange range = [sourceStr rangeOfString:substring];

    [str addAttribute:NSForegroundColorAttributeName
                value:sourceColor
                range:NSMakeRange(0,range.location )];

    [str addAttribute:NSForegroundColorAttributeName value:substringColor range:range];
    [str addAttribute:NSForegroundColorAttributeName
                value:sourceColor
                range:NSMakeRange(range.location + range.length,sourceStr.length - (range.length + range.location))];

    return str;

}

@end

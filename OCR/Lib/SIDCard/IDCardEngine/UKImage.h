// UKImage.h -- extra UIImage methods
// by allen brunson  march 29 2009

#ifndef UKIMAGE_H
#define UKIMAGE_H

#import <UIKit/UIKit.h>

@interface UIImage (UKImage)

-(UIImage*)rotate:(UIImageOrientation)orient;
-(UIImage*)rotateImageOrientation:(UIImageOrientation)orientation;
- (UIImage *)imageWithGaussianBlur;
- (UIImage *)scaleImage:(float)scaleSize;
@end

#endif  // UKIMAGE_H
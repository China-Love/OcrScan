// UKImage.mm -- extra UIImage methods
// by allen brunson  march 29 2009
// based on original code by Kevin Lohman:
// http://blog.logichigh.com/2008/06/05/uiimage-fix/

#include "UKImage.h"

static CGRect swapWidthAndHeight(CGRect rect)
{
    CGFloat  swap = rect.size.width;
    
    rect.size.width  = rect.size.height;
    rect.size.height = swap;
    
    return rect;
}

@implementation UIImage (UKImage)

-(UIImage*)rotate:(UIImageOrientation)orient
{
    CGRect             bnds = CGRectZero;
    UIImage*           copy = nil;
    CGContextRef       ctxt = nil;
    CGImageRef         imag = self.CGImage;
    CGRect             rect = CGRectZero;
    CGAffineTransform  tran = CGAffineTransformIdentity;
	
    rect.size.width  = CGImageGetWidth(imag);
    rect.size.height = CGImageGetHeight(imag);
    
    bnds = rect;
    
    switch (orient)
    {
        case UIImageOrientationUp:
			// would get you an exact copy of the original
			//assert(false);
			return self;
			
        case UIImageOrientationUpMirrored:
			tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
			tran = CGAffineTransformScale(tran, -1.0, 1.0);
			break;
			
        case UIImageOrientationDown:
			tran = CGAffineTransformMakeTranslation(rect.size.width,
													rect.size.height);
			tran = CGAffineTransformRotate(tran, M_PI);
			break;
			
        case UIImageOrientationDownMirrored:
			tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
			tran = CGAffineTransformScale(tran, 1.0, -1.0);
			break;
			
        case UIImageOrientationLeft:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
			tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
			break;
			
        case UIImageOrientationLeftMirrored:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(rect.size.height,
													rect.size.width);
			tran = CGAffineTransformScale(tran, -1.0, 1.0);
			tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
			break;
			
        case UIImageOrientationRight:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
			tran = CGAffineTransformRotate(tran, M_PI / 2.0);
			break;
			
        case UIImageOrientationRightMirrored:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeScale(-1.0, 1.0);
			tran = CGAffineTransformRotate(tran, M_PI / 2.0);
			break;
			
        default:
			// orientation value supplied is invalid
			assert(false);
			return nil;
    }
	
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
	
    switch (orient)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
			CGContextScaleCTM(ctxt, -1.0, 1.0);
			CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
			break;
			
        default:
			CGContextScaleCTM(ctxt, 1.0, -1.0);
			CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
			break;
    }
	
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
    
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return copy;
}

static inline double radians (double degrees) {return degrees * M_PI/180;}
-(UIImage*)rotateImageOrientation:(UIImageOrientation)orientation
{
    UIGraphicsBeginImageContext(self.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, radians(90));
    } else if (orientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, radians(-90));
    } else if (orientation == UIImageOrientationDown) {
        // NOTHING
    } else if (orientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, radians(90));
    }
    
    [self drawAtPoint:CGPointMake(0, 0)];
    
    return UIGraphicsGetImageFromCurrentImageContext();
}

- (UIImage *)imageWithGaussianBlur
{
    float weight[5] = {0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162};
    // Blur horizontally
    UIGraphicsBeginImageContext(self.size);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[0]];
    for (int x = 1; x < 1; ++x) {
        [self drawInRect:CGRectMake(x, 0, self.size.width, self.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[x]];
        [self drawInRect:CGRectMake(-x, 0, self.size.width, self.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[x]];
    }
    UIImage *horizBlurredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // Blur vertically
    UIGraphicsBeginImageContext(self.size);
    [horizBlurredImage drawInRect:CGRectMake(0, 0, self.size.width, self.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[0]];
    for (int y = 1; y < 1; ++y) {
        [horizBlurredImage drawInRect:CGRectMake(0, y, self.size.width, self.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[y]];
        [horizBlurredImage drawInRect:CGRectMake(0, -y, self.size.width, self.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[y]];
    }
    UIImage *blurredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //
    return blurredImage;
}

- (UIImage *)scaleImage:(float)scaleSize
{
    //UIImage *upImage = [UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:UIImageOrientationUp];
    UIGraphicsBeginImageContext(CGSizeMake(self.size.width * scaleSize, self.size.height * scaleSize));
    [self drawInRect:CGRectMake(0, 0, self.size.width * scaleSize, self.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

-(UIImage*)cropImage:(UIImage*)srcImage WithRect:(CGRect)rect
{
    CGImageRef cr = CGImageCreateWithImageInRect(srcImage.CGImage, rect);
    UIImage* cropped = [UIImage imageWithCGImage:cr];
    
    CGImageRelease(cr);
    return cropped;
}

@end
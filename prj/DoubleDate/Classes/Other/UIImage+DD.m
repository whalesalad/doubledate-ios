//
//  NSObject+DD.m
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "NSObject+DD.h"
#import "GPUImage.h"

@implementation UIImage (DD)

- (UIImage *)fixOrientation
{
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
            
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage*)imageOfSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return ret;
}

- (UIImage*)blurImage
{
    GPUImagePicture *sourcePicture = [[[GPUImagePicture alloc] initWithImage:self] autorelease];
    
    GPUImageFastBlurFilter *blurFilter = [[[GPUImageFastBlurFilter alloc] init] autorelease];
    
    [blurFilter setBlurPasses:2.0f];
    [sourcePicture addTarget:blurFilter];
    
//    GPUImageGrayscaleFilter *grayscaleFilter = [[[GPUImageGrayscaleFilter alloc] init] autorelease];
//    [blurFilter addTarget:grayscaleFilter];

    [sourcePicture processImage];
    
    return [blurFilter imageFromCurrentlyProcessedOutput];
}

- (UIImage*)resizableImage
{
    return [self resizableImageWithCapInsets:UIEdgeInsetsMake(self.size.height/2, self.size.width/2, self.size.height/2, self.size.width/2)];
}

- (UIImage*)cutImageWithRect:(CGRect)rect
{
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [self drawInRect:CGRectMake(-rect.origin.x, -rect.origin.y, self.size.width, self.size.height)];
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return ret;
}

+ (UIImage*)clearImage
{
    return [self clearImageOfSize:CGSizeMake(1, 1)];
}

+ (UIImage*)clearImageOfSize:(CGSize)size
{
    return [self imageOfSize:size withColor:[UIColor clearColor]];
}

+ (UIImage*)imageOfSize:(CGSize)size withColor:(UIColor*)color
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGRect fillRect = CGRectMake(0, 0, size.width, size.height);
    CGContextSetFillColorWithColor(currentContext, color.CGColor);
    CGContextFillRect(currentContext, fillRect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

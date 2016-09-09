//
//  UIImage+LXExtension.m
//
//  Created by 从今以后 on 15/9/12.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import AVFoundation.AVUtilities;
#import "UIImage+LXExtension.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIImage (LXExtension)

- (CGFloat)lx_aspectRatio
{
	CGSize size = self.size;
	return size.height / size.width;
}

#pragma mark - 图片缩放 -

- (UIImage *)lx_resizedImageForTargetSize:(CGSize)targetSize
							  contentMode:(UIViewContentMode)contentMode
{
    CGRect drawingRect = { .size = targetSize }; // 默认为 UIViewContentModeScaleToFill

    if (contentMode == UIViewContentModeScaleAspectFit) {
		
        drawingRect.size = [self lx_rectForScaleAspectFitInsideBoundingRect:drawingRect].size;

    } else if (contentMode == UIViewContentModeScaleAspectFill) {

        CGFloat ratio = self.size.height / self.size.width;

        // 先尝试以宽度为准，根据纵横比求出高度
		drawingRect.size.height = targetSize.width * ratio;

		// 若高度不足期望值，说明应以高度为准
        if (drawingRect.size.height < targetSize.height) {
            // 以高度为准，根据纵横比计算宽度
            drawingRect.size = CGSizeMake(targetSize.height / ratio, targetSize.height);
            // 绘制区域的原点 x 坐标需向左平移，从而使裁剪区域居中
            drawingRect.origin.x = -(drawingRect.size.width - targetSize.width) / 2;
        }
		// 在宽度满足期望值的情况下，高度大于等于期望高度。绘制区域原点 y 坐标应向上平移，从而使裁剪区域居中。
        else {
            drawingRect.origin.y = -(drawingRect.size.height - targetSize.height) / 2;
        }
    }

    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0);

    [self drawInRect:drawingRect];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    return image;
}

- (CGRect)lx_rectForScaleAspectFitInsideBoundingRect:(CGRect)boundingRect
{
    return AVMakeRectWithAspectRatioInsideRect(self.size, boundingRect);
}

#pragma mark - 图片裁剪 -

- (UIImage *)lx_roundedImageForCropArea:(CGRect)cropArea
                        backgroundColor:(nullable UIColor *)backgroundColor
{
    return [self lx_roundedImageForCropArea:cropArea
                                borderWidth:0.0
                                borderColor:nil
                            backgroundColor:backgroundColor];
}

- (UIImage *)lx_roundedImageForCropArea:(CGRect)cropArea
							borderWidth:(CGFloat)borderWidth
							borderColor:(nullable UIColor *)borderColor
                        backgroundColor:(nullable UIColor *)backgroundColor
{
    CGSize contextSize = { cropArea.size.width + 2 * borderWidth, cropArea.size.height + 2 * borderWidth };

	UIGraphicsBeginImageContextWithOptions(contextSize, backgroundColor != nil, 0);

    if (backgroundColor) {
        [backgroundColor setFill];
        UIRectFill((CGRect){.size = contextSize});
    }

	// 将外边框路径以内的圆形区域填充为边框颜色
    if (borderWidth > 0) {
        [borderColor setFill];
		[[UIBezierPath bezierPathWithOvalInRect:(CGRect){.size = contextSize}] fill];
    }

    // 内边框原点相对于上下文原点向内偏移 borderWidth，尺寸为图片裁剪尺寸
	CGRect innerBoundaryRect = { .origin = { borderWidth, borderWidth }, .size = cropArea.size };

	// 设置内边框路径以内的圆形区域为裁剪范围
    [[UIBezierPath bezierPathWithOvalInRect:innerBoundaryRect] addClip];

    // 调整图片绘制原点，使裁剪区部分正好对应内边框区域
    CGPoint drawingPoint = { -cropArea.origin.x + borderWidth, -cropArea.origin.y + borderWidth };

    [self drawAtPoint:drawingPoint];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - 创建图片 -

+ (nullable instancetype)lx_imageWithContentsOfFile:(NSString *)path
{
    return [self imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:path ofType:nil]];
}

+ (nullable instancetype)lx_originalRenderingImageNamed:(NSString *)name
{
    return [[self imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

+ (nullable instancetype)lx_imageWithColor:(UIColor *)color
{
    return [self lx_imageWithColor:color size:CGSizeMake(1.0, 1.0) cornerRadius:0.0];
}

+ (nullable instancetype)lx_imageWithColor:(UIColor *)color
									  size:(CGSize)size
							  cornerRadius:(CGFloat)cornerRadius
{
    CGColorRef cg_color = color.CGColor;

    CGFloat alpha = CGColorGetAlpha(cg_color);

    BOOL opaque = (alpha == 1.0 && cornerRadius == 0.0);

    UIGraphicsBeginImageContextWithOptions(size, opaque, 0);

    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), cg_color);

    [[UIBezierPath bezierPathWithRoundedRect:(CGRect){.size = size} cornerRadius:cornerRadius] fill];

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();
	
	return image;
}

#pragma mark - 获取像素颜色 -

- (UIColor *)lx_pixelColorAtPosition:(CGPoint)position
{
    size_t pixelsWide = 1;
    size_t pixelsHigh = 1;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = pixelsWide * 4;
    size_t bitmapByteCount = bytesPerRow * pixelsHigh;

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *bitmapData  = calloc(bitmapByteCount, sizeof(unsigned char));
    CGBitmapInfo bitmapInfo    = (CGBitmapInfo)kCGImageAlphaPremultipliedLast;

    CGContextRef bitmapContext = CGBitmapContextCreate(bitmapData,
                                                       pixelsWide,
                                                       pixelsHigh,
                                                       bitsPerComponent,
                                                       bytesPerRow,
                                                       colorSpace,
                                                       bitmapInfo);

    CGRect rect = CGRectMake(position.x * self.scale, position.y * self.scale, pixelsWide, pixelsHigh);

    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);

    CGContextDrawImage(bitmapContext, CGRectMake(0, 0, pixelsWide, pixelsHigh), imageRef);

    CGFloat alpha = bitmapData[3] / 255.0;
    CGFloat red   = bitmapData[0] / 255.0 / alpha;
    CGFloat green = bitmapData[1] / 255.0 / alpha;
    CGFloat blue  = bitmapData[2] / 255.0 / alpha;

//    NSLog(@"%d %d %d %d", bitmapData[0], bitmapData[1], bitmapData[2], bitmapData[3]);
//    NSLog(@"%f %f %f %f", red, green, blue, alpha);

    free(bitmapData);
    CGImageRelease(imageRef);
    CGContextRelease(bitmapContext);
    CGColorSpaceRelease(colorSpace);

    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark - 生成二维码图片

+ (instancetype)lx_QRCodeImageWithMessage:(NSString *)message
                                     size:(CGSize)size
                                     logo:(nullable UIImage *)logo
                              transparent:(BOOL)transparent
{
    NSData *messageData = [message dataUsingEncoding:NSISOLatin1StringEncoding];
    CIFilter *QRCodeFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [QRCodeFilter setValue:messageData forKey:@"inputMessage"];

    CIImage *outputImage = QRCodeFilter.outputImage;
    CGRect extent = outputImage.extent;
    CGImageRef outputCGImage = [[CIContext contextWithOptions:nil] createCGImage:outputImage fromRect:extent];

    if (transparent) {
        // 为了去除图片透明通道，需要重绘图片
        size_t pixelsWide = CGImageGetWidth(outputCGImage);
        size_t pixelsHigh = CGImageGetHeight(outputCGImage);
        size_t bitsPerComponent = 8;
        size_t bytesPerRow = pixelsWide * 4;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     pixelsWide,
                                                     pixelsHigh,
                                                     bitsPerComponent,
                                                     bytesPerRow,
                                                     colorSpace,
                                                     kCGImageAlphaNoneSkipLast);
        CGColorSpaceRelease(colorSpace);

        // 重绘图片去除透明通道，这样才能使用 CGImageCreateWithMaskingColors 函数
        CGContextDrawImage(context, (CGRect){.size=extent.size}, outputCGImage);
        CGImageRelease(outputCGImage);
        CGImageRef opaqueOutputCGImage = CGBitmapContextCreateImage(context);
        CGContextRelease(context);

        // 去除白色背景
        const CGFloat components[6] = {255,255,255,255,255,255};
        outputCGImage = CGImageCreateWithMaskingColors(opaqueOutputCGImage, components);
        CGImageRelease(opaqueOutputCGImage);
    }

    UIGraphicsBeginImageContextWithOptions(size, !transparent, 0);

    CGContextRef context = UIGraphicsGetCurrentContext();

    // 让二维码更清晰
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);

    // 翻转，不然是上下颠倒的
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1, -1);

    CGContextDrawImage(context, (CGRect){.size=size}, outputCGImage);
    CGImageRelease(outputCGImage);

    if (logo) {
        CGSize logoSize = logo.size;
        CGRect rect = {
            .origin = { size.width/2 - logoSize.width/2, size.height/2 - logoSize.height/2 },
            .size = logoSize
        };
        CGContextDrawImage(context, rect, logo.CGImage);
    }

    UIImage *QRCodeimage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    return QRCodeimage;
}

@end

NS_ASSUME_NONNULL_END

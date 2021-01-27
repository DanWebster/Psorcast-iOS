//
//  PSRImageHelper.swift
//  PsorcastValidation
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//


import UIKit

public class PSRImageHelper {
    
    public static func createPsoriasisDrawSummaryImage(
        aboveFront: UIImage?, belowFront: UIImage?,
        aboveBack: UIImage?, belowBack: UIImage?) -> UIImage? {
        
        // The background image of the full front and back bodies
        // is already scaled to the correct aspect ratio for the
        // device's density.
        // So all we need to do is draw them at the correct offset
        let width = CGFloat(326)
        let height = CGFloat(412)
        let size = CGSize(width: width, height: height)
        
        // See Figma frame Completion Result for x, y, width, height values
        let aboveFrontRect = CGRect(x: 24, y: 9, width: width, height: height)
        let belowFrontRect = CGRect(x: 25, y: 272, width: width, height: height)
        let aboveBackRect = CGRect(x: 403, y: 9, width: width, height: height)
        let belowBackRect = CGRect(x: 402, y: 273, width: width, height: height)
        
        guard let backgroundImage = UIImage(named: "PsoriasisDrawCompletion") else {
            print("Error finding background image")
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(backgroundImage.size, false, 1.0)
                        
        // Resize and draw all the body coverage areas over the background image
        if let aboveFrontUnwrapped = aboveFront {
            aboveFrontUnwrapped.resizeImage(targetSize: size).draw(in: aboveFrontRect)
        }
        if let belowFrontUnwrapped = belowFront {
            belowFrontUnwrapped.resizeImage(targetSize: size).draw(in: belowFrontRect)
        }
        if let aboveBackUnwrapped = aboveBack {
            aboveBackUnwrapped.resizeImage(targetSize: size).draw(in: aboveBackRect)
        }
        if let belowBackUnwrapped = belowBack {
            belowBackUnwrapped.resizeImage(targetSize: size).draw(in: belowBackRect)
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    public static func psoriasisDrawBodySummaryRects(
        aboveFront: CGSize, belowFront: CGSize, aboveBack: CGSize, belowBack: CGSize) ->
        (canvas: CGSize, aboveFront: CGRect, belowFront: CGRect, aboveBack: CGRect, belowBack: CGRect) {
        
        let minWidth = min(min(min(aboveFront.width, belowFront.width), aboveBack.width), belowBack.width)
        let aboveFrontScale = minWidth / aboveFront.width
        let aboveBackScale = minWidth / aboveBack.width
        
        // Border padding
        let horizontalPadding = CGFloat(12)
        let verticalPadding = CGFloat(48)
        
        // The scale between the aboveFront image and the belowFront image sizes
        let frontAboveToBelowScale = CGFloat(179) / CGFloat(181)
        // The scale between the aboveBack image and the belowBack image sizes
        let backAboveToBelowScale = CGFloat(178) / CGFloat(181)
        
        /// It is the vertical space between the front body images divided by width of them
        let frontAboveToBelowVerticalSpacing = CGFloat(212.0 / 375.0)
        /// It is the vertical space between the back body images divided by width of them
        let backAboveToBelowVerticalSpacing = CGFloat(188.0 / 375.0)
        
        let aboveFrontWidth = aboveFront.width * aboveFrontScale
        let aboveFrontHeight = aboveFront.height * aboveFrontScale
        
        let aboveBackWidth = aboveBack.width * aboveBackScale
        let aboveBackHeight = aboveBack.height * aboveBackScale
        
        // To calculate the canvas height, we need to take into consideration
        // the scaled heights of individual images and their veritcal spacing
        let frontVerticalSpacing = aboveFrontWidth * frontAboveToBelowVerticalSpacing
        let belowFrontWidth = aboveFrontWidth * frontAboveToBelowScale
        let belowFrontHeight = belowFrontWidth * (belowFront.height / belowFront.width)
            
        let backVerticalSpacing = aboveBackWidth * backAboveToBelowVerticalSpacing
        let belowBackWidth = aboveBackWidth * backAboveToBelowScale
        let belowBackHeight = belowBackWidth * (belowBack.height / belowBack.width)
        
        // imageHeights is the bigger value of the full body height image of front and back
        let imageHeights = max((aboveFrontHeight + belowFrontHeight) - frontVerticalSpacing, (aboveBackHeight + belowBackHeight) - backVerticalSpacing)
                
        let canvasWidth = (horizontalPadding * 2) + aboveFrontWidth + aboveBackWidth
        let canvasHeight = (verticalPadding * 2) + imageHeights
        let canvasSize = CGSize(width: canvasWidth, height: canvasHeight)
        
        let aboveFrontRect = CGRect(x: horizontalPadding, y: verticalPadding, width: aboveFrontWidth, height: aboveFrontHeight)
        
        let frontCenterAdjustment = (aboveFrontWidth - belowFrontWidth) * CGFloat(0.5)
        let belowFrontRect = CGRect(x: horizontalPadding + frontCenterAdjustment, y: verticalPadding + aboveFrontHeight - frontVerticalSpacing, width: belowFrontWidth, height: belowFrontHeight)
        
        let aboveBackRect = CGRect(x: aboveFrontWidth, y: verticalPadding, width: aboveBackWidth, height: aboveBackHeight)
        
        let belowBackHorizontalOffeset = -CGFloat(1) * (belowBackWidth / CGFloat(375))
        let backCenterAdjustment = ((aboveBackWidth - belowBackWidth) * CGFloat(0.5)) + (belowBackHorizontalOffeset)
        let belowBackRect = CGRect(x: aboveFrontWidth + backCenterAdjustment, y: verticalPadding + aboveBackHeight - backVerticalSpacing, width: belowBackWidth, height: belowBackHeight)
            
        return (canvasSize, aboveFrontRect, belowFrontRect, aboveBackRect, belowBackRect)
    }
    
    public static func createImageCaptureCompletionImage(
        leftImage: UIImage, rightImage: UIImage) -> UIImage? {
        
        let imageRects = self.createImageCaptureCompletionImage(
            leftImage: leftImage.size, rightImage: rightImage.size)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageRects.canvas.width, height: imageRects.canvas.height), false, 1.0)
                        
        leftImage.draw(in: imageRects.leftImage)
        rightImage.draw(in: imageRects.rightImage)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    public static func createImageCaptureCompletionImage(
        leftImage: CGSize, rightImage: CGSize) ->
        (canvas: CGSize, leftImage: CGRect, rightImage: CGRect) {
        
        let leftRect = CGRect(x: 0, y: 0, width: leftImage.width, height: leftImage.height)
        let rightRect = CGRect(x: leftImage.width, y: 0, width: rightImage.width, height: rightImage.height)
            let canvasSize = CGSize(width: leftImage.width + rightImage.width, height: max(leftImage.height, rightImage.height))
            
        return (canvasSize, leftRect, rightRect)
    }
    
    /// Calulate the bounding box of image within the image view
    public static func calculateAspectFit(imageWidth: CGFloat, imageHeight: CGFloat,
                            imageViewWidth: CGFloat, imageViewHeight: CGFloat) -> CGRect {
        
        let imageRatio = (imageWidth / imageHeight)
        let viewRatio = imageViewWidth / imageViewHeight
        if imageRatio < viewRatio {
            let scale = imageViewHeight / imageHeight
            let width = scale * imageWidth
            let topLeftX = (imageViewWidth - width) * 0.5
            return CGRect(x: topLeftX, y: 0, width: width, height: imageViewHeight)
        } else {
            let scale = imageViewWidth / imageWidth
            let height = scale * imageHeight
            let topLeftY = (imageViewHeight - height) * 0.5
            return CGRect(x: 0.0, y: topLeftY, width: imageViewWidth, height: height)
        }
    }
    
    /// Scale the relative x,y of the joint center based on the aspect fit image resize
    /// Then offset the scaled point by the aspect fit left and top bounds
    public static func translateCenterPointToAspectFitCoordinateSpace(imageSize: CGSize, aspectFitRect: CGRect, centerToTranslate: CGPoint, sizeToTranslate: CGSize) -> (leadingTop: CGPoint, size: CGSize) {
        
        let scaleX = (aspectFitRect.width / imageSize.width)
        let scaledCenterX = scaleX * centerToTranslate.x
        let newWidth = scaleX * sizeToTranslate.width
        let leading = (scaledCenterX + aspectFitRect.origin.x) - (newWidth / 2)
        
        let scaleY = (aspectFitRect.height / imageSize.height)
        let scaledCenterY = scaleY * centerToTranslate.y
        let newHeight = scaleY * sizeToTranslate.height
        let top = (scaledCenterY + aspectFitRect.origin.y) - (newHeight / 2)
        
        return (CGPoint(x: leading, y: top), CGSize(width: newWidth, height: newHeight))
    }

    public static func convertToImage(_ view: UIView) -> UIImage {
        return view.asImage()
    }
}

extension UIImage {
    class func imageWithView(_ view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}

extension UIView {
    
    /// Using a function since `var image` might conflict with an existing variable
    /// (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

extension UIImage {
    /// Fix orientation fromt a PNG image taken from the camera
    func fixOrientationForPNG() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
    
    /// Resizes a UIImage to a a different size
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func resizeImageAspectFit(toTargetWidthInPixels: CGFloat) -> UIImage {
        guard let cgImage = self.cgImage else {
            return self
        }
        
        // Target width is in pixels, not points, so calculate density
        let density = CGFloat(self.size.width) / CGFloat(cgImage.width)
        // And apply that density to the target pixels to make all images the same true width
        let targetWidthInPts = toTargetWidthInPixels * density
        // Compute the aspect ratio of the image
        let aspectRatio = CGFloat(cgImage.height) / CGFloat(cgImage.width)
        let targetSizeInPts = CGSize(width: targetWidthInPts, height: aspectRatio * targetWidthInPts)
                
        return self.resizeImage(targetSize: targetSizeInPts)
    }
    
    func cropImage(rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x *= self.scale
        rect.origin.y *= self.scale
        rect.size.width *= self.scale
        rect.size.height *= self.scale

        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
}

extension UIColor {

    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red: red, green: green, blue: blue, alpha: alpha)
    }

    var redComponent: CGFloat {
        var red: CGFloat = 0.0
        getRed(&red, green: nil, blue: nil, alpha: nil)

        return red
    }

    var greenComponent: CGFloat {
        var green: CGFloat = 0.0
        getRed(nil, green: &green, blue: nil, alpha: nil)

        return green
    }

    var blueComponent: CGFloat {
        var blue: CGFloat = 0.0
        getRed(nil, green: nil, blue: &blue, alpha: nil)

        return blue
    }

    var alphaComponent: CGFloat {
        var alpha: CGFloat = 0.0
        getRed(nil, green: nil, blue: nil, alpha: &alpha)

        return alpha
    }
}

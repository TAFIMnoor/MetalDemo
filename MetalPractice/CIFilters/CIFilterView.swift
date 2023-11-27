//
//  CIFilterView.swift
//  MetalPractice
//
//  Created by mohammad noor uddin on 14/11/23.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct CIFilterView: View {
    
    let context = CIContext()
    
    @State private var showingImagePicker: Bool = false
    @State private var inputImage: UIImage?
    @State private var image: Image?
    
    @StateObject var dataModel = DataModel()
    @State var currentFilterName: String?
    
    @State var showSlider: Bool = false
    @State var sliderValue: Double = 0
    
    @State var showSecondSlider: Bool = false
    @State var secondSliderValue: Double = 0
    
    let filterNames: [String] = ["Blur","FishEye","Glass","Four","Nine","Multi","SWIRL","TILT SHIFT","KALEIDO","Sunlight",
                                 "VERTICAL FLIP","HORIZONTAL FLIP","FLIP QUAD","MOSAIC","Two Horizontal","Two Vertical",
                                 "Mirror Up&Down","Mirror Sideway","CIPhotoEffectMono","CILightTunnel","CILineOverlay",
                                 "CIHexagonalPixellate"]
    
    var body: some View {
        VStack {
            
            Spacer()
            
            image?
                .resizable()
                .scaledToFit()
            
            Spacer()
            
            VStack {
                
                if showSlider {
                    HStack {
                        Text("Range")
                            .font(.headline)
                            .padding(EdgeInsets(top: 0.0, leading: 5.0, bottom: 15.0, trailing: 5.0))
                        
                        Slider(value: $sliderValue, in: 0...10)
                            .padding(EdgeInsets(top: 0.0, leading: 20.0,
                                                bottom: 10, trailing: 20.0))
                            .onChange(of: sliderValue) { value in
                                applyProcessing(filterName: currentFilterName!)
                            }
                    }
                    
                    if showSecondSlider {
                        HStack {
                            Text("Blur")
                                .font(.headline)
                                .padding(EdgeInsets(top: 0.0, leading: 5.0, bottom: 15.0, trailing: 5.0))
                            
                            Slider(value: $secondSliderValue, in: 0...10)
                                .padding(EdgeInsets(top: 0.0, leading: 0.0,
                                                    bottom: 10, trailing: 20.0))
                                .onChange(of: secondSliderValue) { value in
                                    applyProcessing(filterName: currentFilterName!)
                                }
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    
                    Button(action: {
                        showingImagePicker = true
                    }, label: {
                        Text("Select Image")
                    })
                    .font(.headline)
                    .foregroundColor(Color.white)
                    .frame(height: 40)
                    .padding(10)
                    .background(Color.blue)
                    .cornerRadius(10)
                    
                    ScrollView([.horizontal], showsIndicators: false) {
                        HStack {
                            ForEach(filterNames.indices, id: \.self) { id in
                                Text(filterNames[id])
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(height: 40)
                                    .padding(10)
                                    .background(Color.secondary)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        showSlider = false
                                        showSecondSlider = false
                                        sliderValue = 5.0
                                        secondSliderValue = 5.0
                                        currentFilterName = filterNames[id]
                                        applyProcessing(filterName: filterNames[id])
                                    }
                            }
                        }
                    }
                }
                .frame(height: 100)
            }
            .frame(height: 200)
        }
        .onChange(of: inputImage) { _ in loadImage() }
        .sheet(isPresented: $showingImagePicker, content: {
            ImagePicker(image: $inputImage)
        })
    }
    
    func loadImage() {
        guard let inputImage = inputImage else {
            print("Image Loading Error!")
            return
        }
        
        let resizeInputImage = resizeImage(image: inputImage,
                                           targetSize: preferredImageSize(currentSize: inputImage.size,
                                                                          targetWidth: 600.0))
        image = Image(uiImage: resizeInputImage)
        dataModel.image = resizeInputImage
        dataModel.restoreImage = resizeInputImage
    }
    
    private func preferredImageSize(currentSize: CGSize, targetWidth: CGFloat) -> CGSize {
        let originalSize = currentSize
        let aspectRatio = originalSize.width / originalSize.height
        let targetHeight = targetWidth / aspectRatio
        let newSize = CGSize(width: targetWidth, height: targetHeight)
        return newSize
    }

    
    private func applyProcessing(filterName: String) {
        
        guard let UserSelectedImage = dataModel.image else {
            return
        }
        
        if filterName == "FishEye" {
            
            showSlider = true
            let intensity = Float(sliderValue * 0.08)
            let outputImage = bumpDistortion(toImage: dataModel.restoreImage!,
                                               radius: Float(dataModel.restoreImage!.size.width * 0.5),
                                               intensity: intensity)!
            image = Image(uiImage: outputImage)

        } else if filterName == "Blur" {
            
            showSlider = true
            let ciImage = CIImage(image: dataModel.restoreImage!)!
            let blurIntensity = sliderValue * 2.0
            let gaussianBlur = gaussianBlur(inputImage: ciImage,
                                           inputRadius: blurIntensity as NSNumber)!
            
            guard let imageBlur = gaussianBlur.outputImage?.cropped(to: ciImage.extent) else {
                return
            }
            
            if let cgimg = context.createCGImage(imageBlur, from: imageBlur.extent) {
                let processedImage = UIImage(cgImage: cgimg)
                image = Image(uiImage: processedImage)
            }
            
        } else if filterName == "Multi" {
            
            showSlider = true
            let intensity = (sliderValue/1.25) >= 1.0 ? (1.0 + (sliderValue/1.25).rounded() * 0.25) : 1.0
            let processedImage = affineTile(inputImage: dataModel.restoreImage!, intensity: intensity)!
            image = Image(uiImage: processedImage)
            
        } else if filterName == "Two Horizontal" {
            
            let processedImage = TileTwo(inputImage: dataModel.restoreImage!)!
            image = Image(uiImage: processedImage)
            
        } else if filterName == "Two Vertical" {
            
            let processedImage = TileTwoVertical(inputImage: dataModel.restoreImage!)!
            image = Image(uiImage: processedImage)
            
        } else if filterName == "Four"{
            
            let processedImage = TileFour(inputImage: dataModel.restoreImage!)!
            image = Image(uiImage: processedImage)
            
        } else if filterName == "Nine"{
            
            let processedImage = TileNine(inputImage: dataModel.restoreImage!)!
            image = Image(uiImage: processedImage)
            
        } else if filterName == "VERTICAL FLIP" {
            
            let processedImage = kaleidoscope(inputImage: dataModel.restoreImage!,
                                           inputCount: 1,
                                           inputCenter: CIVector(x: dataModel.image!.size.width * 0.5,
                                                                 y: dataModel.image!.size.height * 0.5),
                                           inputAngle: 0.0)!
            image = Image(uiImage: processedImage)
            
            
        } else if filterName == "HORIZONTAL FLIP" {
            
            let processedImage = kaleidoscope(inputImage: dataModel.restoreImage!,
                                           inputCount: 1,
                                           inputCenter: CIVector(x: dataModel.image!.size.width * 0.5,
                                                                 y: dataModel.image!.size.height * 0.5),
                                           inputAngle: (-3.14 * 0.5) as NSNumber)!
            image = Image(uiImage: processedImage)
            
        } else if filterName == "FLIP QUAD" {
                        
            let processedImage = kaleidoscope(inputImage: dataModel.restoreImage!,
                                           inputCount: 2,
                                           inputCenter: CIVector(x: dataModel.image!.size.width * 0.5,
                                                                 y: dataModel.image!.size.height * 0.5),
                                           inputAngle: (-3.14 * 0.0) as NSNumber)!
            image = Image(uiImage: processedImage)
            
        } else if filterName == "KALEIDO" {
            
            /// - parameter inputImage: The image to use as an input image. For filters that also use a background image, this is the foreground image.
            /// - parameter inputCount: The number of reflections in the pattern. defaultValue = 6.
            /// - parameter inputCenter: The x and y position to use as the center of the effect defaultValue = [150 150].
            /// - parameter inputAngle: The angle of reflection. defaultValue = 0.
            
            showSlider = true
            let intensity = (sliderValue/0.5).rounded()
            if intensity > 0.0 {
                let processedImage = kaleidoscope(inputImage: dataModel.restoreImage!,
                                               inputCount: intensity as NSNumber,
                                               inputCenter: CIVector(x: dataModel.image!.size.width * 0.5,
                                                                     y: dataModel.image!.size.height * 0.5),
                                               inputAngle: (3.14 * 0.50) as NSNumber)!
                image = Image(uiImage: processedImage)
                    
            } else {
                let processedImage = dataModel.restoreImage!
                image = Image(uiImage: processedImage)
            }
            
        } else if filterName == "CILineOverlay" {
            
            /// - parameter inputImage: The image to use as an input image. For filters that also use a background image, this is the foreground image.
            /// - parameter inputNRNoiseLevel: The noise level of the image (used with camera data) that gets removed before tracing the edges of the image. Increasing the noise level helps to clean up the traced edges of the image. defaultValue = 0.07000000000000001.
            /// - parameter inputNRSharpness: The amount of sharpening done when removing noise in the image before tracing the edges of the image. This improves the edge acquisition. defaultValue = 0.71.
            /// - parameter inputEdgeIntensity: The accentuation factor of the Sobel gradient information when tracing the edges of the image. Higher values find more edges, although typically a low value (such as 1.0) is used. defaultValue = 1.
            /// - parameter inputThreshold: This value determines edge visibility. Larger values thin out the edges. defaultValue = 0.1.
            /// - parameter inputContrast: The amount of anti-aliasing to use on the edges produced by this filter. Higher values produce higher contrast edges (they are less anti-aliased). defaultValue = 50.

            let processedImage = lineOverlay(inputImage: dataModel.restoreImage!, inputNRNoiseLevel: 0.07,
                                          inputNRSharpness: 0.71, inputEdgeIntensity: 3.0,
                                          inputThreshold: 0.1, inputContrast: 50)!
            image = Image(uiImage: processedImage)
            
        } else if filterName == "Glass" {
            
            /// - parameter inputImage: The image to use as an input image. For filters that also use a background image, this is the foreground image.
            /// - parameter inputTexture: A texture to apply to the source image.
            /// - parameter inputCenter: The center of the effect as x and y coordinates. defaultValue = [150 150].
            /// - parameter inputScale: The amount of texturing of the resulting image. The larger the value, the greater the texturing. defaultValue = 200.
            
            showSlider = true
            let intensity = sliderValue * 15.0
            let glassTexture = UIImage(named: "glassTexture")!
            let texture = resizeImage(image: glassTexture, targetSize: CGSize(width: dataModel.restoreImage!.size.width * 1.5,
                                                                              height: dataModel.restoreImage!.size.height * 1.5))
            
            let processedImage = glassDistortion(inputImage: dataModel.restoreImage!,
                                                 inputTexture: CIImage(image: texture)!,
                                                 inputCenter: CIVector(x: texture.size.width * 0.0,
                                                                       y: texture.size.height * 1.0),
                                                 inputScale: intensity as NSNumber)!
            image = Image(uiImage: processedImage)
            
        } else if filterName == "CIDepthOfField" {
            
            /// - parameter inputImage: The image to use as an input image. For filters that also use a background image, this is the foreground image.
            /// - parameter inputPoint0:  defaultValue = [0 300].
            /// - parameter inputPoint1:  defaultValue = [300 300].
            /// - parameter inputSaturation: The amount to adjust the saturation. defaultValue = 1.5.
            /// - parameter inputUnsharpMaskRadius:  defaultValue = 2.5.
            /// - parameter inputUnsharpMaskIntensity:  defaultValue = 0.5.
            /// - parameter inputRadius: The distance from the center of the effect. defaultValue = 6.

            let processedImage = depthOfField(inputImage: dataModel.restoreImage!,
                                           inputPoint0: CIVector(x: dataModel.image!.size.width * 0.5,
                                                                 y: dataModel.image!.size.height * 0.5),
                                           inputPoint1: CIVector(x: dataModel.image!.size.width * 0.5,
                                                                 y: dataModel.image!.size.height * 1.0),
                                           inputSaturation: 1.5,
                                           inputUnsharpMaskRadius: 20.5,
                                           inputUnsharpMaskIntensity: 0.5,
                                           inputRadius: 50)!
            
        } else if filterName == "Sunlight" {
            
            /// - parameter inputCenter: The x and y position to use as the center of the sunbeam pattern defaultValue = [150 150].
            /// - parameter inputColor: The color of the sun. defaultValue = (1 0.5 0 1) <CGColorSpace 0x6040000af9c0> (kCGColorSpaceDeviceRGB).
            /// - parameter inputSunRadius: The radius of the sun. defaultValue = 40.
            /// - parameter inputMaxStriationRadius: The radius of the sunbeams. defaultValue = 2.58.
            /// - parameter inputStriationStrength: The intensity of the sunbeams. Higher values result in more intensity. defaultValue = 0.5.
            /// - parameter inputStriationContrast: The contrast of the sunbeams. Higher values result in more contrast. defaultValue = 1.375.
            /// - parameter inputTime: The duration of the effect. defaultValue = 0.
            
            showSlider = true
            let ciImage = CIImage(image: dataModel.restoreImage!)!
            let sunCenterXposition = 1.0 - (sliderValue * 0.1)
            let sunbeam = sunbeamsGenerator(inputCenter: CIVector(x: dataModel.image!.size.width * sunCenterXposition,
                                                                  y: dataModel.image!.size.height * 1.0),
                                            inputColor: CIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0),
                                            inputSunRadius: (dataModel.image!.size.width * 0.1) as NSNumber,
                                            inputMaxStriationRadius: (dataModel.image!.size.width * 1.0) as NSNumber,
                                            inputStriationStrength: 0.00003,
                                            inputStriationContrast: 500.375,
                                            inputTime: 0)!
            
            guard let imageSunbeam = sunbeam.outputImage?.cropped(to: ciImage.extent) else {
                return
            }

            let output = imageSunbeam.composited(over: ciImage)
            
            if let cgimg = context.createCGImage(output, from: output.extent) {
                let processedImage = UIImage(cgImage: cgimg)
                image = Image(uiImage: processedImage)
            }
            
        } else if filterName == "CILenticularHaloGenerator" {
            
            /// - parameter inputCenter: The x and y position to use as the center of the halo. defaultValue = [150 150].
            /// - parameter inputColor: A color. defaultValue = (1 0.9 0.8 1) <CGColorSpace 0x6040000af9c0> (kCGColorSpaceDeviceRGB).
            /// - parameter inputHaloRadius: The radius of the halo. defaultValue = 70.
            /// - parameter inputHaloWidth: The width of the halo, from its inner radius to its outer radius. defaultValue = 87.
            /// - parameter inputHaloOverlap:  defaultValue = 0.77.
            /// - parameter inputStriationStrength: The intensity of the halo colors. Larger values are more intense. defaultValue = 0.5.
            /// - parameter inputStriationContrast: The contrast of the halo colors. Larger values are higher contrast. defaultValue = 1.
            /// - parameter inputTime: The duration of the effect. defaultValue = 0.
            ///
            let ciImage = CIImage(image: dataModel.image!)!
            let lenticularHalo = lenticularHaloGenerator(inputCenter: CIVector(x: ciImage.extent.width * 0.5,
                                                                               y: ciImage.extent.height * 0.5),
                                                         inputColor: CIColor(red: 1.0, green: 0.9, blue: 0.8, alpha: 1.0),
                                                         inputHaloRadius: 110, inputHaloWidth: 87,
                                                         inputHaloOverlap: 0.77, inputStriationStrength: 0.5,
                                                         inputStriationContrast: 2.0, inputTime: 0)!
            
            guard let image = lenticularHalo.outputImage?.cropped(to: ciImage.extent) else {
                return
            }
            
            guard let cgimg = context.createCGImage(image, from: image.extent) else {
                return
            }
//            let newCiImage = CIImage(cgImage: cgimg)
            
            // MARK: Converting Halo effect image to equal height & width
            let cgToUi = UIImage(cgImage: cgimg)
            let equalSize = resizeImage(image: cgToUi, targetSize: ciImage.extent.size)
            let newCiImage = CIImage(image: equalSize)!
            dataModel.image = equalSize
            
            //MARK: Halo effet and light tunnel effect merge
            let lightTunnel = lightTunnel(inputImage: newCiImage,
                                          inputCenter: CIVector(x: newCiImage.extent.width * 0.5,
                                                                y: newCiImage.extent.height * 0.5),
                                          inputRotation: 3,
                                          inputRadius: 100)!
            
            guard let finalImage = lightTunnel.outputImage?.cropped(to: ciImage.extent) else {
                return
            }
//            let output = finalImage.composited(over: ciImage)
            
            if let cgimg = context.createCGImage(finalImage, from: finalImage.extent) {
                let processedImage = UIImage(cgImage: cgimg)
                //dataModel.image = processedImage
            }
            
        } else if filterName == "CILightTunnel" {
            
            /// - parameter inputImage: The image to process.
            /// - parameter inputCenter: Center of the light tunnel. defaultValue = [150 150].
            /// - parameter inputRotation: Rotation angle of the light tunnel. defaultValue = 0.
            /// - parameter inputRadius: Center radius of the light tunnel. defaultValue = 100.
            
            let ciImage = CIImage(image: dataModel.restoreImage!)!
            let lightTunnel = lightTunnel(inputImage: ciImage,
                                          inputCenter: CIVector(x: ciImage.extent.width * 0.5,
                                                                y: ciImage.extent.height * 0.5),
                                          inputRotation: 1,
                                          inputRadius: 100)!
            
            guard let imageLight = lightTunnel.outputImage?.cropped(to: ciImage.extent) else {
                return
            }
            
            if let cgimg = context.createCGImage(imageLight, from: imageLight.extent) {
                let processedImage = UIImage(cgImage: cgimg)
                image = Image(uiImage: processedImage)
            }
    
            
        } else if filterName == "SWIRL" {
            
            /// - parameter inputImage: The image to use as an input image. For filters that also use a background image, this is the foreground image.
            /// - parameter inputCenter: The center of the effect as x and y coordinates. defaultValue = [150 150].
            /// - parameter inputRadius: The radius determines how many pixels are used to create the distortion. The larger the radius, the wider the extent of the distortion. defaultValue = 300.
            /// - parameter inputAngle: The angle (in radians) of the twirl. Values can be positive or negative. defaultValue = 3.141592653589793.
            
            showSlider = true
            let rotation = (sliderValue * 0.05 * 3.14)
            let ciImage = CIImage(image: dataModel.restoreImage!)!
            let twirlDistortion = twirlDistortion(inputImage: ciImage,
                                                  inputCenter: CIVector(x: ciImage.extent.width * 0.5,
                                                                        y: ciImage.extent.height * 0.5),
                                                  inputRadius: (ciImage.extent.width * 0.4) as NSNumber,
                                                  inputAngle: rotation as NSNumber)!
            
            if let cgimg = context.createCGImage((twirlDistortion.outputImage!), from: (twirlDistortion.outputImage!.extent)) {
                let processedImage = UIImage(cgImage: cgimg)
                image = Image(uiImage: processedImage)
            }
            
        } else if filterName == "MOSAIC" {
            
            /// - parameter inputImage: The image to use as an input image. For filters that also use a background image, this is the foreground image.
            /// - parameter inputCenter: The x and y position to use as the center of the effect defaultValue = [150 150].
            /// - parameter inputScale: The scale determines the size of the squares. Larger values result in larger squares. defaultValue = 8.
        
            showSlider = true
            let inputScale = 6.0 + (sliderValue * 2.0)
            
            let ciImage = CIImage(image: dataModel.restoreImage!)!
            let pixellate = pixellate(inputImage: ciImage,
                                            inputCenter: CIVector(x: ciImage.extent.width * 0.5,
                                                                  y: ciImage.extent.height * 0.5),
                                      inputScale: inputScale as NSNumber)!
            
            if let cgimg = context.createCGImage((pixellate.outputImage!), from: (pixellate.outputImage!.extent)) {
                let processedImage = UIImage(cgImage: cgimg)
                image = Image(uiImage: processedImage)
            }
            
        } else if filterName == "CIHexagonalPixellate" {
            
            let ciImage = CIImage(image: dataModel.restoreImage!)!
            let hexagonalPixellate = hexagonalPixellate(inputImage: ciImage,
                                               inputCenter: CIVector(x: ciImage.extent.width * 0.5,
                                                                     y: ciImage.extent.height * 0.5),
                                               inputScale: (ciImage.extent.width * 0.01) as NSNumber)!
            
            if let cgimg = context.createCGImage((hexagonalPixellate.outputImage!), from: (hexagonalPixellate.outputImage!.extent)) {
                let processedImage = UIImage(cgImage: cgimg)
                image = Image(uiImage: processedImage)
            }
            
        } else if filterName == "CIPointillize" {
            
            let ciImage = CIImage(image: dataModel.restoreImage!)!
            let pointillize = pointillize(inputImage: ciImage,
                                        inputRadius: 3,
                                        inputCenter: CIVector(x: ciImage.extent.width * 0.5,
                                                              y: ciImage.extent.height * 0.5))!
            
            if let cgimg = context.createCGImage((pointillize.outputImage!), from: (pointillize.outputImage!.extent)) {
                let processedImage = UIImage(cgImage: cgimg)
                image = Image(uiImage: processedImage)
            }
            
        } else if filterName == "TILT SHIFT" {
            
            let ciImage = CIImage(image: dataModel.restoreImage!)!
            
            // MARK: Create Mask to produce blur region in actual image
            var whiteMask = UIImage(named: "WhiteBackground")!
            var blackMask = UIImage(named: "black")!
            
            if whiteMask.size.equalTo(ciImage.extent.size) == false {
                whiteMask = resizeImage(image: whiteMask, targetSize: ciImage.extent.size)
                blackMask = resizeImage(image: blackMask, targetSize: CGSize(width: ciImage.extent.size.width,
                                                                                        height: ciImage.extent.size.height * 0.33))
            }
            
            // MARK: Control Mask Movement here
            showSlider = true
            let focusAreaPosition = (sliderValue * 0.07)
            var finalMaskForBlur: UIImage?
            if focusAreaPosition.isEqual(to: dataModel.previousValue) == false {
                finalMaskForBlur = drawLogoIn(whiteMask,
                                                  blackMask,
                                                  position: CGPoint(x: whiteMask.size.width * 0.0,
                                                                    y: whiteMask.size.height * focusAreaPosition))
            }
            
            // MARK: Control out of focus area Blur intensity here
            showSecondSlider = true
            let blurIntensity = (secondSliderValue * 1.5)
            let convertedMaskSize = resizeImage(image: finalMaskForBlur!, targetSize: ciImage.extent.size)
            let ciImageMask = CIImage(image: convertedMaskSize)!
            let maskedVariableBlur = maskedVariableBlur(inputImage: ciImage,
                                                        inputMask: ciImageMask,
                                                        inputRadius: blurIntensity as NSNumber)!
            
            guard let imageBlur = maskedVariableBlur.outputImage?.cropped(to: ciImage.extent) else {
                return
            }
            
            if let cgimg = context.createCGImage(imageBlur, from: (imageBlur.extent)) {
                let processedImage = UIImage(cgImage: cgimg)
                image = Image(uiImage: processedImage)
            }
            
        } else if filterName == "Mirror Up&Down"{
            
            let processedImage = mirrorUpAndDown(inputImage: dataModel.restoreImage!)!
            image = Image(uiImage: processedImage)
            
        } else if filterName == "Mirror Sideway"{
            
            let processedImage = mirrorSideway(inputImage: dataModel.restoreImage!)!
            image = Image(uiImage: processedImage)
            
        } else {
            
            let imageInputX = dataModel.restoreImage
            let beginImage = CIImage(image: imageInputX!)!
            let currentFilter = CIFilter(name: filterName)
            currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
            if let cgimg = context.createCGImage((currentFilter?.outputImage!)!, from: (currentFilter?.outputImage!.extent)!) {
                let processedImage = UIImage(cgImage: cgimg)
                image = Image(uiImage: processedImage)
            }
            
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * heightRatio)
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func bumpDistortion(toImage currentImage: UIImage, radius : Float, intensity: Float) -> UIImage? {
        let currentFilter = CIFilter(name: "CIBumpDistortion")
        let beginImage = CIImage(image: currentImage)
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)


        currentFilter!.setValue(radius, forKey: kCIInputRadiusKey)
        currentFilter!.setValue(intensity, forKey: kCIInputScaleKey)
        currentFilter!.setValue(CIVector(x: currentImage.size.width * 0.5,
                                         y: currentImage.size.height * 0.5),
                                forKey: kCIInputCenterKey)
        
        guard let image = currentFilter?.outputImage?.cropped(to: beginImage!.extent) else {
            return nil
        }
        if let cgimg = context.createCGImage(image, from: image.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            return processedImage
        }
        return nil
    }
    

    func affineTile(inputImage: UIImage, intensity: Double) -> UIImage? {
        let currentFilter = CIFilter(name: "CIAffineTile")
        let beginImage = CIImage(image: inputImage)
        
        //   - parameter inputTransform: The transform to apply to the image.
        //     defaultValue = CGAffineTransform: {{1, 0, 0, 1}, {0, 0}}.
        let inputTransform = NSValue(cgAffineTransform:  CGAffineTransform(a: 0.25, b: 0.0,
                                                                           c: 0.0, d: 0.25,
                                                                           tx: 0.0, ty: 0.0))
        currentFilter!.setDefaults()
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(inputTransform, forKey: kCIInputTransformKey)

        // MARK: affline Tile (Multi)
        guard let image = currentFilter?.outputImage?.cropped(to: CGRect(x: 0, y: 0,
                                                                         width: intensity * beginImage!.extent.width,
                                                                         height: intensity * beginImage!.extent.height)) else {
            return nil
        }
        
        if let cgimg = context.createCGImage(image, from: image.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            return processedImage
        }
        return nil
    }
    
    func TileTwoVertical(inputImage: UIImage) -> UIImage? {
        let currentFilter = CIFilter(name: "CIAffineTile")
        
        let resizedImage = resizeImage(image: inputImage, targetSize: CGSize(width: inputImage.size.width * 1.0,
                                                                            height: inputImage.size.height * 1.0))
        
        let beginImage = CIImage(image: resizedImage)
        
        //   - parameter inputTransform: The transform to apply to the image.
        //     defaultValue = CGAffineTransform: {{1, 0, 0, 1}, {0, 0}}.
        let inputTransform = NSValue(cgAffineTransform:  CGAffineTransform(a: 0.5, b: 0.0,
                                                                           c: 0.0, d: 1.0,
                                                                           tx: 0.0, ty: 0.0))
        currentFilter!.setDefaults()
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(inputTransform, forKey: kCIInputTransformKey)
        
        guard let image = currentFilter?.outputImage?.cropped(to: beginImage!.extent) else {
            return nil
        }
        
        if let cgimg = context.createCGImage(image, from: image.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            return processedImage
        }
        return nil
    }
    
    func TileTwo(inputImage: UIImage) -> UIImage? {
        let currentFilter = CIFilter(name: "CIAffineTile")
        
        let resizedImage = resizeImage(image: inputImage, targetSize: CGSize(width: inputImage.size.width * 1.0,
                                                                            height: inputImage.size.height * 1.0))
        
        let beginImage = CIImage(image: resizedImage)
        
        //   - parameter inputTransform: The transform to apply to the image.
        //     defaultValue = CGAffineTransform: {{1, 0, 0, 1}, {0, 0}}.
        let inputTransform = NSValue(cgAffineTransform:  CGAffineTransform(a: 1.0, b: 0.0,
                                                                           c: 0.0, d: 0.5,
                                                                           tx: 0.0, ty: 0.0))
        currentFilter!.setDefaults()
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(inputTransform, forKey: kCIInputTransformKey)
        
        guard let image = currentFilter?.outputImage?.cropped(to: beginImage!.extent) else {
            return nil
        }
        
        if let cgimg = context.createCGImage(image, from: image.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            return processedImage
        }
        return nil
    }
    
    func TileFour(inputImage: UIImage) -> UIImage? {
        let currentFilter = CIFilter(name: "CIAffineTile")
        let beginImage = CIImage(image: inputImage)
        
        //   - parameter inputTransform: The transform to apply to the image.
        //     defaultValue = CGAffineTransform: {{1, 0, 0, 1}, {0, 0}}.
        let inputTransform = NSValue(cgAffineTransform:  CGAffineTransform(a: 1.0, b: 0.0,
                                                                           c: 0.0, d: 1.0,
                                                                           tx: 0.0, ty: 0.0))
        currentFilter!.setDefaults()
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(inputTransform, forKey: kCIInputTransformKey)
        
        // MARK: affline Tile 2X2
        guard let image = currentFilter?.outputImage?.cropped(to: CGRect(x: 0, y: 0,
                                                                         width: 2 * beginImage!.extent.width,
                                                                         height: 2 * beginImage!.extent.height)) else {
            return nil
        }
        
        if let cgimg = context.createCGImage(image, from: image.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            return processedImage
        }
        return nil
    }
    
    func TileNine(inputImage: UIImage) -> UIImage? {
        let currentFilter = CIFilter(name: "CIAffineTile")
        let beginImage = CIImage(image: inputImage)
        
        //   - parameter inputTransform: The transform to apply to the image.
        //     defaultValue = CGAffineTransform: {{1, 0, 0, 1}, {0, 0}}.
        let inputTransform = NSValue(cgAffineTransform:  CGAffineTransform(a: 1.0, b: 0.0,
                                                                           c: 0.0, d: 1.0,
                                                                           tx: 0.0, ty: 0.0))
        currentFilter!.setDefaults()
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(inputTransform, forKey: kCIInputTransformKey)
        
        // MARK: affline Tile 3X3
        guard let image = currentFilter?.outputImage?.cropped(to: CGRect(x: 0, y: 0,
                                                                         width: 3.0 * beginImage!.extent.width,
                                                                         height: 3.0 * beginImage!.extent.height)) else {
            return nil
        }
        
        if let cgimg = context.createCGImage(image, from: image.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            return processedImage
        }
        return nil
    }
    
    func kaleidoscope(inputImage: UIImage, inputCount: NSNumber, inputCenter: CIVector, inputAngle: NSNumber) -> UIImage? {
        
        let inputImage = CIImage(image: inputImage)
        guard let currentFilter = CIFilter(name: "CIKaleidoscope") else {
            return nil
        }
        
        currentFilter.setDefaults()
        currentFilter.setValue(inputImage, forKey: kCIInputImageKey)
        currentFilter.setValue(inputCount, forKey: "inputCount")
        currentFilter.setValue(inputCenter, forKey: kCIInputCenterKey)
        currentFilter.setValue(inputAngle, forKey: kCIInputAngleKey)
        
        guard let image = currentFilter.outputImage?.cropped(to: inputImage!.extent) else {
            return nil
        }
//        guard let image = currentFilter.outputImage else {
//            return nil
//        }
        if let cgimg = context.createCGImage(image, from: image.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            return processedImage
        }
        return nil
    }
    
    func lineOverlay(inputImage: UIImage, inputNRNoiseLevel: NSNumber,
                     inputNRSharpness: NSNumber, inputEdgeIntensity: NSNumber,
                     inputThreshold: NSNumber, inputContrast: NSNumber) -> UIImage? {
        
        guard let currentFilter = CIFilter(name: "CILineOverlay") else {
            return nil
        }
        
        let inputImage = CIImage(image: inputImage)
        
        currentFilter.setDefaults()
        currentFilter.setValue(inputImage, forKey: kCIInputImageKey)
        currentFilter.setValue(inputNRNoiseLevel, forKey: "inputNRNoiseLevel")
        currentFilter.setValue(inputNRSharpness, forKey: "inputNRSharpness")
        currentFilter.setValue(inputEdgeIntensity, forKey: "inputEdgeIntensity")
        currentFilter.setValue(inputThreshold, forKey: "inputThreshold")
        currentFilter.setValue(inputContrast, forKey: kCIInputContrastKey)
        
        guard let image = currentFilter.outputImage?.cropped(to: inputImage!.extent) else {
            return nil
        }
        if let cgimg = context.createCGImage(image, from: image.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            return processedImage
        }
        return nil
    }
    
    func glassDistortion(inputImage: UIImage, inputTexture: CIImage, inputCenter: CIVector, inputScale: NSNumber) -> UIImage? {
        guard let filter = CIFilter(name: "CIGlassDistortion") else {
            return nil
        }
        print(inputImage.size)
        let inputImage = CIImage(image: inputImage)
        print(inputImage!.extent.size)
        filter.setDefaults()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(inputTexture, forKey: "inputTexture")
        filter.setValue(inputCenter, forKey: kCIInputCenterKey)
        filter.setValue(inputScale, forKey: kCIInputScaleKey)
        
        guard let image = filter.outputImage?.cropped(to: inputImage!.extent) else {
            return nil
        }
        if let cgimg = context.createCGImage(image, from: image.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            return processedImage
        }
        return nil
    }
    
    func depthOfField(inputImage: UIImage,
                      inputPoint0: CIVector,
                      inputPoint1: CIVector,
                      inputSaturation: NSNumber,
                      inputUnsharpMaskRadius: NSNumber,
                      inputUnsharpMaskIntensity: NSNumber,
                      inputRadius: NSNumber) -> UIImage? {
        
        guard let filter = CIFilter(name: "CIDepthOfField") else {
            return nil
        }
        let inputImage = CIImage(image: inputImage)
        
        filter.setDefaults()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(inputPoint0, forKey: "inputPoint0")
        filter.setValue(inputPoint1, forKey: "inputPoint1")
        filter.setValue(inputSaturation, forKey: "inputSaturation")
        filter.setValue(inputUnsharpMaskRadius, forKey: "inputUnsharpMaskRadius")
        filter.setValue(inputUnsharpMaskIntensity, forKey: "inputUnsharpMaskIntensity")
        filter.setValue(inputRadius, forKey: kCIInputRadiusKey)
        
        guard let image = filter.outputImage?.cropped(to: inputImage!.extent) else {
            return nil
        }
        if let cgimg = context.createCGImage(image, from: image.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            return processedImage
        }
        return nil
    }
    
    func sunbeamsGenerator(inputCenter: CIVector, inputColor: CIColor, inputSunRadius: NSNumber,
                           inputMaxStriationRadius: NSNumber, inputStriationStrength: NSNumber,
                           inputStriationContrast: NSNumber, inputTime: NSNumber) -> CIFilter? {
        guard let filter = CIFilter(name: "CISunbeamsGenerator") else {
            return nil
        }
        
        filter.setDefaults()
        filter.setValue(inputCenter, forKey: kCIInputCenterKey)
        filter.setValue(inputColor, forKey: kCIInputColorKey)
        filter.setValue(inputSunRadius, forKey: "inputSunRadius")
        filter.setValue(inputMaxStriationRadius, forKey: "inputMaxStriationRadius")
        filter.setValue(inputStriationStrength, forKey: "inputStriationStrength")
        filter.setValue(inputStriationContrast, forKey: "inputStriationContrast")
        filter.setValue(inputTime, forKey: kCIInputTimeKey)
        
        return filter
    }
    
    func lenticularHaloGenerator(inputCenter: CIVector, inputColor: CIColor, inputHaloRadius: NSNumber,
                                        inputHaloWidth: NSNumber, inputHaloOverlap: NSNumber, inputStriationStrength: NSNumber,
                                        inputStriationContrast: NSNumber, inputTime: NSNumber) -> CIFilter? {
        
        guard let filter = CIFilter(name: "CILenticularHaloGenerator") else {
            return nil
        }
        
        filter.setDefaults()
        filter.setValue(inputCenter, forKey: kCIInputCenterKey)
        filter.setValue(inputColor, forKey: kCIInputColorKey)
        filter.setValue(inputHaloRadius, forKey: "inputHaloRadius")
        filter.setValue(inputHaloWidth, forKey: "inputHaloWidth")
        filter.setValue(inputHaloOverlap, forKey: "inputHaloOverlap")
        filter.setValue(inputStriationStrength, forKey: "inputStriationStrength")
        filter.setValue(inputStriationContrast, forKey: "inputStriationContrast")
        filter.setValue(inputTime, forKey: kCIInputTimeKey)
        
        return filter
    }
    
    func lightTunnel(inputImage: CIImage, inputCenter: CIVector, inputRotation: NSNumber, inputRadius: NSNumber) -> CIFilter? {
        guard let filter = CIFilter(name: "CILightTunnel") else {
            return nil
        }
        filter.setDefaults()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(inputCenter, forKey: kCIInputCenterKey)
        filter.setValue(inputRotation, forKey: "inputRotation")
        filter.setValue(inputRadius, forKey: kCIInputRadiusKey)
        return filter
    }
    
    func twirlDistortion(inputImage: CIImage, inputCenter: CIVector, inputRadius: NSNumber, inputAngle: NSNumber) -> CIFilter? {
        guard let filter = CIFilter(name: "CITwirlDistortion") else {
            return nil
        }
        filter.setDefaults()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(inputCenter, forKey: kCIInputCenterKey)
        filter.setValue(inputRadius, forKey: kCIInputRadiusKey)
        filter.setValue(inputAngle, forKey: kCIInputAngleKey)
        return filter
    }
    
    func pixellate(inputImage: CIImage, inputCenter: CIVector, inputScale: NSNumber) -> CIFilter? {
        guard let filter = CIFilter(name: "CIPixellate") else {
            return nil
        }
        filter.setDefaults()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(inputCenter, forKey: kCIInputCenterKey)
        filter.setValue(inputScale, forKey: kCIInputScaleKey)
        return filter
    }
    
    func hexagonalPixellate(inputImage: CIImage, inputCenter: CIVector, inputScale: NSNumber) -> CIFilter? {
        guard let filter = CIFilter(name: "CIHexagonalPixellate") else {
            return nil
        }
        filter.setDefaults()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(inputCenter, forKey: kCIInputCenterKey)
        filter.setValue(inputScale, forKey: kCIInputScaleKey)
        return filter
    }
    
    func pointillize(inputImage: CIImage, inputRadius: NSNumber, inputCenter: CIVector) -> CIFilter? {
        guard let filter = CIFilter(name: "CIPointillize") else {
            return nil
        }
        filter.setDefaults()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(inputRadius, forKey: kCIInputRadiusKey)
        filter.setValue(inputCenter, forKey: kCIInputCenterKey)
        return filter
    }
    
    func maskedVariableBlur(inputImage: CIImage, inputMask: CIImage, inputRadius: NSNumber) -> CIFilter? {
        guard let filter = CIFilter(name: "CIMaskedVariableBlur") else {
            return nil
        }
        filter.setDefaults()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(inputMask, forKey: "inputMask")
        filter.setValue(inputRadius, forKey: kCIInputRadiusKey)
        return filter
    }
    
    func mirrorUpAndDown(inputImage: UIImage) -> UIImage? {
        let beginImage = CIImage(image: inputImage)!

        let flipTransform = CGAffineTransform(a: 1.0, b: 0.0,
                                              c: 0.0, d: -1.0,
                                              tx: 0.0, ty: 0.0)

        let flippedImage = beginImage.transformed(by: flipTransform)
        let cgImage = context.createCGImage(flippedImage, from: flippedImage.extent)!
        return UIImage(cgImage: cgImage)
    }
    
    func mirrorSideway(inputImage: UIImage) -> UIImage? {
        let beginImage = CIImage(image: inputImage)!

        let flipTransform = CGAffineTransform(a: -1.0, b: 0.0,
                                              c: 0.0, d: 1.0,
                                              tx: 0.0, ty: 0.0)


        let flippedImage = beginImage.transformed(by: flipTransform)
        let cgImage = context.createCGImage(flippedImage, from: flippedImage.extent)!
        return UIImage(cgImage: cgImage)
    }
    
    func gaussianBlur(inputImage: CIImage, inputRadius: NSNumber) -> CIFilter? {
        guard let filter = CIFilter(name: "CIGaussianBlur") else {
            return nil
        }
        filter.setDefaults()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(inputRadius, forKey: kCIInputRadiusKey)
        return filter
    }
    
    private func drawLogoIn(_ image: UIImage, _ logo: UIImage, position: CGPoint) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { context in
            image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
            logo.draw(in: CGRect(origin: position, size: logo.size))
        }
    }
}

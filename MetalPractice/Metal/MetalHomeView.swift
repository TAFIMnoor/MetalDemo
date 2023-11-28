//
//  ContentView.swift
//  MetalPractice
//
//  Created by mohammad noor uddin on 26/11/23.
//

import SwiftUI

struct MetalHomeView: View {
    
    @State var translationXAxis: Double = 0
    @State var translationYAxis: Double = 0
    @State var scale: Double = 1.0
    @State var rotation: Double = 0.0
    
    @State private var showingImagePicker: Bool = false
    @State private var test: Bool = false
    @State private var inputImage: UIImage?
    
    var body: some View {
        VStack {
            
            if (inputImage?.cgImage != nil && test ) {
                SwiftUIView {
                    MetalView(textureCgImage: (inputImage?.cgImage!)!, uiImage: inputImage)
                }
                .frame(width: CGFloat(MetalModel.constants.size.x),
                       height: CGFloat(MetalModel.constants.size.y))
            }
            
            Spacer()
            
            Button(action: {
                showingImagePicker = true
                test = false
            }, label: {
                Text("Select Image")
            })
            .font(.headline)
            
            ScrollView([.vertical]) {
                HStack {
                    Text("Move X")
                        .font(.headline)
                        .padding(EdgeInsets(top: 0.0, leading: 5.0, bottom: 15.0, trailing: 5.0))
                    
                    Slider(value: $translationXAxis, in: -1...1)
                        .padding(EdgeInsets(top: 0.0, leading: 20.0,
                                            bottom: 10, trailing: 20.0))
                        .onChange(of: translationXAxis) { value in
                            MetalModel.constants.moveOnXaxis = Float(value)
                        }
                }
                
                HStack {
                    Text("Move Y")
                        .font(.headline)
                        .padding(EdgeInsets(top: 0.0, leading: 5.0, bottom: 15.0, trailing: 5.0))
                    
                    Slider(value: $translationYAxis, in: -1...1)
                        .padding(EdgeInsets(top: 0.0, leading: 20.0,
                                            bottom: 10, trailing: 20.0))
                        .onChange(of: translationYAxis) { value in
                            MetalModel.constants.moveOnYaxis = Float(value)
                        }
                }
                
                HStack {
                    Text("Zoom")
                        .font(.headline)
                        .padding(EdgeInsets(top: 0.0, leading: 5.0, bottom: 15.0, trailing: 5.0))
                    
                    Slider(value: $scale, in: 0.2...3)
                        .padding(EdgeInsets(top: 0.0, leading: 20.0,
                                            bottom: 10, trailing: 20.0))
                        .onChange(of: scale) { value in
                            MetalModel.constants.scale = Float(value)
                        }
                }
                
                HStack {
                    Text("Rotate")
                        .font(.headline)
                        .padding(EdgeInsets(top: 0.0, leading: 5.0, bottom: 15.0, trailing: 1.0))
                    
                    Slider(value: $rotation, in: -5...5)
                        .padding(EdgeInsets(top: 0.0, leading: 20.0,
                                            bottom: 20, trailing: 20.0))
                        .onChange(of: rotation) { value in
                            MetalModel.constants.angleOfRotation = Float(value)
                        }
                }
            }
            .frame(height: 100)
            
        }
        .onChange(of: inputImage) { _ in
            loadImage()
            updateSliderValues()
        }
        .sheet(isPresented: $showingImagePicker, content: {
            ImagePicker(image: $inputImage)
        })
    }
    
    func loadImage() {
        guard let _ = inputImage else { return }
        test = true
    }
    
    func updateSliderValues() {
        translationXAxis = 0
        translationYAxis = 0
        scale = 1.0
        rotation = 0.0
    }
    
}

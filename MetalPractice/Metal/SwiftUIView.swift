//
//  ContentView.swift
//  MetalPractice
//
//  Created by mohammad noor uddin on 9/11/23.
//

import SwiftUI
import MetalKit


// MARK: SwiftUI + Metal
public struct SwiftUIView: UIViewRepresentable {
    public var wrappedView: UIView
    
    private var handleUpdateUIView: ((UIView, Context) -> Void)?
    private var handleMakeUIView: ((Context) -> UIView)?
    
    public init(closure: () -> UIView) {
        wrappedView = closure()
    }
    
    public func makeUIView(context: Context) -> UIView {
        guard let handler = handleMakeUIView else {
            return wrappedView
        }
        
        return handler(context)
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        print("updated")
        handleUpdateUIView?(uiView, context)
    }
}

public extension SwiftUIView {
    mutating func setMakeUIView(handler: @escaping (Context) -> UIView) -> Self {
        handleMakeUIView = handler
        return self
    }
    
    mutating func setUpdateUIView(handler: @escaping (UIView, Context) -> Void) -> Self {
        handleUpdateUIView = handler
        return self
    }
}

// MARK: Metal Stuff
class MetalView: MTKView {
    var renderer: Renderer!
    var texture: MTLTexture!
    
    init(textureCgImage: CGImage, uiImage: UIImage? = nil) {
        print("In Device")
        super.init(frame: .zero, device: MTLCreateSystemDefaultDevice())
        // Make sure we are on a device that can run metal!
        guard let defaultDevice = device else {
            fatalError("Device loading error")
        }
        colorPixelFormat = .bgra8Unorm
        // Our clear color, can be set to any color
        clearColor = MTLClearColor(red: 0.1, green: 0.57, blue: 0.25, alpha: 1)
        createRenderer(device: defaultDevice, textureCgImage: textureCgImage)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createRenderer(device: MTLDevice, textureCgImage: CGImage){
        do {
            self.texture = try loadTexture(device: device, cgImage: textureCgImage)
            print("Texture is changing:", texture.height)
        } catch {
            print("Error occured in loadTexture Function: ", "\(error.localizedDescription)")
        }
        renderer = Renderer(device: device, texture: self.texture)
        self.delegate = renderer
    }
    
    func loadTexture(device: MTLDevice, cgImage: CGImage) throws -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: device)
        let texture = try textureLoader.newTexture(cgImage: cgImage)
        return texture
    }
    
}

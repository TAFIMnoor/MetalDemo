//
//  Renderer.swift
//  MetalPractice
//
//  Created by mohammad noor uddin on 26/11/23.
//

import Foundation
import MetalKit

class Renderer: NSObject {
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState!
    
    var vertexBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    var textureSize: SIMD2<Float>!
    var texture: MTLTexture!
    var sampler: MTLSamplerState!
    
    var vertices: [Vertex] = [
         Vertex(position: SIMD3<Float>(-1,1,0), color: SIMD4<Float>(1,0,0,1), texture: SIMD2<Float>(0,0)),
         Vertex(position: SIMD3<Float>(-1,-1,0), color: SIMD4<Float>(0,1,0,1), texture: SIMD2<Float>(0,1)),
         Vertex(position: SIMD3<Float>(1,-1,0), color: SIMD4<Float>(0,0,1,1), texture: SIMD2<Float>(1,1)),
         Vertex(position: SIMD3<Float>(1,1,0), color: SIMD4<Float>(1,0,0,1), texture: SIMD2<Float>(1,0))
    ]
    var indices: [UInt16] = [
       0,1,2,
       2,3,0
    ]
    
    init(device: MTLDevice, texture: MTLTexture) {
        super.init()
        self.texture = texture
        self.textureSize = SIMD2<Float>(Float(texture.width), Float(texture.height))
        createCommandQueue(device: device)
        createBuffers(device: device)
        buildSamplerState(device: device)
        createPipelineState(device: device)
    }
    
    //MARK: Builders
    func createCommandQueue(device: MTLDevice) {
        commandQueue = device.makeCommandQueue()
    }
    
    func createPipelineState(device: MTLDevice) {
        // The device will make a library for us
        let library = device.makeDefaultLibrary()
        // Our vertex function name
        let vertexFunction = library?.makeFunction(name: "vertex_shader")
        // Our fragment function name
        let fragmentFunction = library?.makeFunction(name: "fragment_shader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm_srgb

        let vertexDiscriptor = MTLVertexDescriptor()
        
        vertexDiscriptor.attributes[0].format = .float3
        vertexDiscriptor.attributes[0].offset = 0
        vertexDiscriptor.attributes[0].bufferIndex = 0
        
        vertexDiscriptor.attributes[1].format = .float4
        vertexDiscriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
        vertexDiscriptor.attributes[1].bufferIndex = 0
        
        vertexDiscriptor.attributes[2].format = .float2
        vertexDiscriptor.attributes[2].offset = MemoryLayout<SIMD3<Float>>.stride + MemoryLayout<SIMD4<Float>>.stride
        vertexDiscriptor.attributes[2].bufferIndex = 0
        
        vertexDiscriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        pipelineDescriptor.vertexDescriptor = vertexDiscriptor
        
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("PipeLine State Error: ","\(error.localizedDescription)")
        }
    }
    
    func createBuffers(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: MemoryLayout<Vertex>.stride * vertices.count,
                                         options: [])
        indexBuffer = device.makeBuffer(bytes: indices,
                                        length: MemoryLayout<UInt16>.size * indices.count)
    }
    
    func buildSamplerState(device: MTLDevice) {
        let descriptor = MTLSamplerDescriptor()
        descriptor.minFilter = .linear
        descriptor.magFilter = .linear
        sampler = device.makeSamplerState(descriptor: descriptor)
    }
    
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {

        guard let drawable = view.currentDrawable else {
            return
        }
        let renderPassDescriptor = view.currentRenderPassDescriptor
        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
        commandEncoder?.setRenderPipelineState(renderPipelineState)
        
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.setVertexBytes(&MetalModel.constants, length: MemoryLayout<Constants>.stride, index: 1)

        commandEncoder?.setFragmentTexture(texture, index: 0)
        commandEncoder?.setFragmentSamplerState(sampler, index: 0)
        commandEncoder?.setFragmentBytes(&MetalModel.constants, length: MemoryLayout<Constants>.stride, index: 0)
        commandEncoder?.setFragmentBytes(&textureSize, length: MemoryLayout<SIMD2<Float>>.stride, index: 1)
        commandEncoder?.drawIndexedPrimitives(type: .triangleStrip,
                                              indexCount: indices.count,
                                              indexType: .uint16,
                                              indexBuffer: indexBuffer,
                                              indexBufferOffset: 0)
        
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}

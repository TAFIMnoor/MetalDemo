//
//  Shader.metal
//  MetalPractice
//
//  Created by mohammad noor uddin on 9/11/23.
//

#include <metal_stdlib>
using namespace metal;

struct Constants {
    float moveOnXaxis;
    float moveOnYaxis;
    float scale;
    float angle;
    float2 size;
    float contentMode;
};

struct VertexIn {
    float4 position [[ attribute(0)]];
    float4 color [[ attribute(1) ]];
    float2 textureCoord [[ attribute(2) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
    float2 textureCoord;
};

vertex VertexOut vertex_shader(const VertexIn vertexIn [[ stage_in ]],
                               constant Constants &constants [[ buffer(1) ]]) {
    VertexOut vertexOut;
    
    vertexOut.position = vertexIn.position;
    vertexOut.color = vertexIn.color;
    vertexOut.textureCoord = vertexIn.textureCoord;
    
    return vertexOut;
}

fragment half4 fragment_shader(VertexOut vertexIn [[stage_in]],
                               texture2d<float, access::sample> sourceTexture [[texture(0)]],
                               sampler sourceSampler [[sampler(0)]],
                               constant float2 &textureSize [[ buffer(1) ]],
                               constant Constants &constants [[ buffer(0) ]])
{
    float2 uv = vertexIn.textureCoord - 0.5;
    float4 tempCoord = float4(uv,1,1);
    
    float textureAspect = (float)textureSize.x / (float)textureSize.y;
    float frameAspect = (float)constants.size.x / (float)constants.size.y;
    
    // MARK: Translate
    float4x4 translationMatrix = float4x4(float4(1,0,0,-constants.moveOnXaxis),
                                          float4(0,1,0,-constants.moveOnYaxis),
                                          float4(0,0,1,0),
                                          float4(0,0,0,1));
    
    float4 transResult = tempCoord * translationMatrix;
    tempCoord = transResult;
    
    // MARK: Rotation
    float2x2 rotationMatrix = float2x2(float2(cos(constants.angle), -sin(constants.angle)),
                                       float2(sin(constants.angle), cos(constants.angle)));
    
    float2 position = float2(tempCoord.x * frameAspect, tempCoord.y);
    float2 rotationResult = position * rotationMatrix;
    tempCoord = float4(rotationResult, 1, 1);
    
    // MARK: Scale
    float scale = 1 / constants.scale;
    float4x4 scaleMatrix = float4x4(float4(scale,0,0,0),
                                    float4(0,scale,0,0),
                                    float4(0,0,scale,0),
                                    float4(0,0,0,1));
    
    float4 scaleResult = tempCoord * scaleMatrix;
    tempCoord = scaleResult;
    
    uv = float2(tempCoord.x, tempCoord.y) + 0.5;
    
    
    // Calculate Aspect Ratio for both Texture and Expected output texture
//    float textureAspect = (float)sourceTexture.get_width() / (float)sourceTexture.get_height();
//    float frameAspect = (float)constants.size.x / (float)constants.size.y;
    
    
    float scaleX = 1, scaleY = 1;
    float textureFrameRatio = textureAspect / frameAspect;
    bool portraitFrame = frameAspect < 1;
    
    // Aspect Fit
    if(portraitFrame)
        scaleY = textureFrameRatio;
    else
        scaleX = 1.f / textureFrameRatio;
    
    
    float2 textureScale = float2(scaleX, textureAspect);
    uv = textureScale * (uv - 0.5) + 0.5;
    
    // Points outside image
    if (uv.x > 1.0 || uv.y > 1.0 || uv.x < 0.0 || uv.y < 0.0) { return half4(0,0,0,1); }
    
    //if (uv.x > 0.5) { return half4(1,0.8,0,1); }
    
    return half4(sourceTexture.sample(sourceSampler, uv));
}

//
//  Types.swift
//  MetalPractice
//
//  Created by mohammad noor uddin on 26/11/23.
//

import Foundation
import SwiftUI

struct Vertex {
    var position: SIMD3<Float>
    var color: SIMD4<Float>
    var texture: SIMD2<Float>
}

struct Constants {
    var moveOnXaxis: Float = 0.0
    var moveOnYaxis: Float = 0.0
    var scale: Float = 1.0
    var angleOfRotation: Float = 0.0
    var size: SIMD2<Float> = SIMD2<Float>(Float(UIScreen.main.bounds.width), Float(UIScreen.main.bounds.height * 0.7))
    var contentMode: Float = 1.0
}

struct ImageData {
    static let uiImage = UIImage(named: "butterfly")!
    static var renderImage: CGImage? = nil
}

class MetalModel {
    static var constants = Constants()
}




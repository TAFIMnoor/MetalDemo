//
//  DataModel.swift
//  MetalPractice
//
//  Created by mohammad noor uddin on 14/11/23.
//

import Foundation
import SwiftUI

class DataModel: ObservableObject {
    @Published var image: UIImage?
    @Published var restoreImage: UIImage?
    var previousValue = Double.greatestFiniteMagnitude
}

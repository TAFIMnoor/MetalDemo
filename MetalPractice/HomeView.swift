//
//  HomeView.swift
//  MetalPractice
//
//  Created by mohammad noor uddin on 27/11/23.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink("CiFilters", destination: CIFilterView())
                    .font(.title2)
                    .padding(15)
                    .foregroundStyle(Color.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                
                NavigationLink("Metal", destination: MetalHomeView())
                    .font(.title2)
                    .padding(20)
                    .foregroundStyle(Color.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

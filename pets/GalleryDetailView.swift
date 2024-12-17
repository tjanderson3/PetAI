//
//  GalleryDetailView.swift
//  pets
//
//  Created by Teddy Anderson on 6/20/24.
//

import Foundation
import SwiftUI

struct GalleryImage: Identifiable {
    let id = UUID()
    let imagePath: String
}

struct GalleryDetailView: View {
    let galleryImages: [GalleryImage]
    let petId: String
    let petName: String
    
    @State private var selectedImageIndex: Int = 0
    
    var body: some View {
        VStack {
            Spacer()
            Divider()
                .background(Color.white)
            if let uiImage = UIImage(contentsOfFile: galleryImages[selectedImageIndex].imagePath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.darkBackground)
            }
            Spacer()
            Divider()
                .background(Color.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(0..<galleryImages.count, id: \.self) { index in
                        if let uiImage = UIImage(contentsOfFile: galleryImages[index].imagePath) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(index == selectedImageIndex ? Color.yellow : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    selectedImageIndex = index
                                }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: 120)
            .background(Color.darkBackground)
        }
        .background(Color.darkBackground)
        .navigationTitle("\(petName)'s Gallery")
        .navigationBarTitleDisplayMode(.inline)
    }
}

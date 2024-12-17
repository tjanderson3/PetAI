//
//  Modifiers.swift
//  pets
//
//  Created by Blake Anderson on 5/31/24.
//

import Foundation
import SwiftUI
import StoreKit
import UIKit

extension Color {
    static let mainTextColor = Color(red: 95/255, green: 93/255, blue: 93/255)
    static let actionColor = Color(red: 255/255, green: 197/255, blue: 0/255)
    static let descriptionText = Color.white
    static let darkBackground = Color(red: 28/255, green: 28/255, blue: 28/255)
}

struct OnboardingTitles: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Outfit", size: 30)) // Adjust size as needed
            .foregroundColor(Color.actionColor)
            .fontWeight(.black) // Adjust the weight as needed
             // Adjust the color as needed
    }
}

struct OnboardingInfo: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Nunito", size: 16)) // Adjust size as needed
            .foregroundColor(Color.descriptionText)
            .fontWeight(.regular) // Adjust the weight as needed
             // Adjust the color as needed
            .multilineTextAlignment(.leading)

    }
}

struct ContinueButton: View {
    var body: some View {
        Text("Continue")
            .font(.custom("Nunito", size: 20))
            .foregroundColor(.darkBackground)
            .frame(width: UIScreen.main.bounds.width * 0.9, height: 60)
            .background(Color.actionColor)
            .cornerRadius(50)
    }
}

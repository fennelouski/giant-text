//
//  CharacterAnimation.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import SwiftUI

struct CharacterAnimation {
    var scale: CGFloat = 1.0
    var offset: CGSize = .zero
    var rotation: Double = 0
}

struct CharacterView: View {
    let character: Character
    let index: Int
    let totalCharacters: Int
    let fontSize: CGFloat
    let colorScheme: ColorScheme
    let animation: TextAnimation
    let intensity: Double
    let characterAnimation: CharacterAnimation
    let isClippingEnabled: Bool
    let useSerifFont: Bool
    let isBold: Bool
    let isItalicized: Bool
    
    var body: some View {
        Text(String(character))
            .font(createFont())
            #if os(watchOS)
            .foregroundColor(.white)
            #else
            .foregroundColor(colorScheme == .dark ? .white : .black)
            #endif
            .opacity(0.8) // Set opacity to 80%
            .scaleEffect(characterAnimation.scale)
            .offset(characterAnimation.offset)
            .rotationEffect(.degrees(characterAnimation.rotation))
    }
    
    private func createFont() -> Font {
        let weight: Font.Weight = isBold ? .bold : .regular
        
        if useSerifFont {
            return .system(size: fontSize, weight: weight, design: .serif)
        } else {
            return .system(size: fontSize, weight: weight, design: .default)
        }
    }
} 

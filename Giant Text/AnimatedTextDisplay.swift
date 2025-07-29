//
//  AnimatedTextDisplay.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import SwiftUI

struct AnimatedTextDisplay: View {
    let attributedText: NSAttributedString
    let fontSize: CGFloat
    let colorScheme: ColorScheme
    let animation: TextAnimation
    let intensity: Double
    let isClippingEnabled: Bool
    let useSerifFont: Bool
    let kerning: Double
    let isBold: Bool
    let isItalicized: Bool

    @State private var animationPhase: Double = 0
    @State private var characterAnimations: [CharacterAnimation] = []
    @State private var animationTimer: Timer?
    @State private var isAnimationActive: Bool = false
    
    var body: some View {
        // Use consistent character-based rendering for ALL animations, including .none
        ZStack {
            HStack(spacing: kerning) { // Use kerning value for letter spacing
                ForEach(Array(attributedText.string.enumerated()), id: \.offset) { index, character in
                    CharacterView(
                        character: character,
                        index: index,
                        totalCharacters: attributedText.string.count,
                        fontSize: fontSize,
                        colorScheme: colorScheme,
                        animation: animation,
                        intensity: intensity,
                        characterAnimation: characterAnimations.indices.contains(index) ? characterAnimations[index] : CharacterAnimation(),
                        isClippingEnabled: isClippingEnabled,
                        useSerifFont: useSerifFont,
                        isBold: isBold,
                        isItalicized: isItalicized
                    )
                }
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped(antialiased: isClippingEnabled)
        .allowsHitTesting(false)
        .onAppear { setupCharacterAnimations() }
        .onChange(of: animation) { _, _ in 
            // Immediately reset and restart animation
            DispatchQueue.main.async {
                setupCharacterAnimations()
            }
        }
        .onChange(of: intensity) { _, _ in 
            // Immediately reset and restart animation with new intensity
            DispatchQueue.main.async {
                setupCharacterAnimations()
            }
        }
        .onChange(of: attributedText) { _, _ in setupCharacterAnimations() }
        .onChange(of: useSerifFont) { _, _ in setupCharacterAnimations() }
        .onChange(of: kerning) { _, _ in 
            // Kerning changes don't require animation reset, just view update
        }
        .onDisappear { animationTimer?.invalidate(); animationTimer = nil }
    }
    
    private func setupCharacterAnimations() {
        // Immediately stop any existing animations and reset state
        animationTimer?.invalidate()
        animationTimer = nil
        isAnimationActive = false
        
        // Immediately reset all character animations to default state
        for i in characterAnimations.indices {
            characterAnimations[i] = CharacterAnimation()
        }
        
        // Create fresh character animations array
        characterAnimations = Array(repeating: CharacterAnimation(), count: attributedText.string.count)
        
        // Start new animation based on current settings
        switch animation {
        case .none:
            // No animation timers needed - characters remain at default state (scale: 1.0, offset: .zero, rotation: 0)
            break
        case .ripple:
            startIndividualRippleAnimation()
        case .jitter:
            startIndividualJitterAnimation()
        case .bloom:
            startIndividualBloomAnimation()
        }
    }
    
    // MARK: - Individual Letter Bloom Animation
    private func startIndividualBloomAnimation() {
        let scaleUpDuration: TimeInterval = 0.6
        let holdDuration: TimeInterval = 0.035
        let scaleDownDuration: TimeInterval = 0.5
        let stagger: TimeInterval = 0.05
        let totalLetters = characterAnimations.count
        let totalCycleDuration = (stagger * Double(max(0, totalLetters-1))) + scaleUpDuration + holdDuration + scaleDownDuration + 0.5
        isAnimationActive = true
        
        func animateCycle() {
            guard isAnimationActive else { return }
            for i in 0..<totalLetters {
                let startDelay = stagger * Double(i)
                DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
                    guard isAnimationActive else { return }
                    // Scale up
                    withAnimation(.easeInOut(duration: scaleUpDuration)) {
                        characterAnimations[i].scale = 1.3
                    }
                    // Hold
                    DispatchQueue.main.asyncAfter(deadline: .now() + scaleUpDuration) {
                        guard isAnimationActive else { return }
                        // Hold for holdDuration, then scale down
                        DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration) {
                            guard isAnimationActive else { return }
                            withAnimation(.easeInOut(duration: scaleDownDuration)) {
                                characterAnimations[i].scale = 1.0
                            }
                        }
                    }
                }
            }
            // Schedule next cycle
            animationTimer = Timer.scheduledTimer(withTimeInterval: totalCycleDuration, repeats: false) { _ in
                if isAnimationActive {
                    animateCycle()
                }
            }
        }
        animateCycle()
    }
    
    private func startIndividualJitterAnimation() {
        let jitterDuration: ()->TimeInterval = { .random(in: 0.025...0.05) / intensity }
        let coolOffDuration = 2.0
        let totalCycleDuration = 3.0 + coolOffDuration // 3 seconds of jittering + 2 seconds cool-off
        
        isAnimationActive = true
        
        func startIndividualJitterCycle() {
            guard isAnimationActive else { return }
            
            // Start with current intensity and ease in
            var currentIntensity: Double = 0.0
            let fullJitterDuration = 2.0
            let easeOutDuration = 0.5
            
            // Ease in phase
            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                guard isAnimationActive else {
                    timer.invalidate()
                    return
                }
                
                currentIntensity += 0.1
                if currentIntensity >= intensity {
                    currentIntensity = intensity
                    timer.invalidate()
                    
                    // Full jitter phase - animate each character individually
                    let fullJitterTimer = Timer.scheduledTimer(
                        withTimeInterval: jitterDuration(),
                        repeats: true
                    ) { jitterTimer in
                        guard isAnimationActive else {
                            jitterTimer.invalidate()
                            return
                        }
                        
                        let currentMaxOffset = CGFloat(currentIntensity * 8)
                        
                        // Update each character's animation individually
                        for index in characterAnimations.indices {
                            withAnimation(.easeInOut(duration: jitterDuration())) {
                                characterAnimations[index].offset = CGSize(
                                    width: CGFloat.random(in: -currentMaxOffset...currentMaxOffset),
                                    height: CGFloat.random(in: -currentMaxOffset...currentMaxOffset)
                                )
                                characterAnimations[index].rotation = Double.random(in: -15...15)
                            }
                        }
                    }
                    
                    // Stop full jitter after duration
                    DispatchQueue.main.asyncAfter(deadline: .now() + fullJitterDuration) {
                        fullJitterTimer.invalidate()
                        
                        // Ease out phase
                        let easeOutTimer = Timer.scheduledTimer(
                            withTimeInterval: 0.005,
                            repeats: true
                        ) { easeOutTimer in
                            guard isAnimationActive else {
                                easeOutTimer.invalidate()
                                return
                            }
                            
                            currentIntensity -= 0.1
                            if currentIntensity <= 0 {
                                currentIntensity = 0
                                easeOutTimer.invalidate()
                                
                                // Reset all characters to normal position
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    for index in characterAnimations.indices {
                                        characterAnimations[index].offset = .zero
                                        characterAnimations[index].rotation = 0
                                    }
                                }
                            }
                        }
                        
                        // Stop ease out after duration
                        DispatchQueue.main.asyncAfter(
                            deadline: .now() + easeOutDuration
                        ) {
                            easeOutTimer.invalidate()
                        }
                    }
                }
            }
            
            // Schedule next cycle after cool-off period
            animationTimer = Timer.scheduledTimer(withTimeInterval: totalCycleDuration, repeats: false) { _ in
                if isAnimationActive {
                    startIndividualJitterCycle()
                }
            }
        }
        
        startIndividualJitterCycle()
    }
    
    private func startIndividualRippleAnimation() {
        let jumpUpDuration: TimeInterval = 0.3
        let jumpDownDuration: TimeInterval = 0.25
        let stagger: TimeInterval = 0.05
        let totalLetters = characterAnimations.count
        let totalCycleDuration = (stagger * Double(max(0, totalLetters-1))) + jumpUpDuration + jumpDownDuration + 1.0
        isAnimationActive = true
        
        func animateCycle() {
            guard isAnimationActive else { return }
            for i in 0..<totalLetters {
                let startDelay = stagger * Double(i)
                DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
                    guard isAnimationActive else { return }
                    // Jump up
                    withAnimation(.easeOut(duration: jumpUpDuration)) {
                        characterAnimations[i].offset = CGSize(
                            width: 0,
                            height: -intensity * 20
                        )
                    }
                    // Hold
                    DispatchQueue.main.asyncAfter(deadline: .now() + jumpUpDuration) {
                        guard isAnimationActive else { return }
                        // Hold for holdDuration, then jump down
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            guard isAnimationActive else { return }
                            withAnimation(.easeIn(duration: jumpDownDuration)) {
                                characterAnimations[i].offset = .zero
                            }
                        }
                    }
                }
            }
            // Schedule next cycle
            animationTimer = Timer.scheduledTimer(withTimeInterval: totalCycleDuration, repeats: false) { _ in
                if isAnimationActive {
                    animateCycle()
                }
            }
        }
        animateCycle()
    }
} 

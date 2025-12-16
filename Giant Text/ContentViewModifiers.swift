//
//  ContentViewModifiers.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import SwiftUI
#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit
#endif

extension View {
    func contentViewModifiers(
        state: ContentViewState,
        actions: ContentViewActions
    ) -> some View {
        let view1 = self
            .onChange(of: state.attributedText) { oldValue, newValue in
                actions.updateDocument(attributedText: newValue)
                actions.addToHistory(oldValue: oldValue, newValue: newValue)
            }
            .onAppear {
                actions.loadDocument()
                actions.setupOrientationObserver()
            }
        
        let view2 = view1
            .onChange(of: state.selectedAnimation) { _, newValue in
                UserDefaults.standard.set(newValue.rawValue, forKey: "selectedAnimation")
            }
            .onChange(of: state.animationIntensity) { _, newValue in
                UserDefaults.standard.set(newValue, forKey: "animationIntensity")
            }
            .onChange(of: state.isClippingEnabled) { _, newValue in
                UserDefaults.standard.set(newValue, forKey: "isClippingEnabled")
            }

        let view2b = view2
            .onChange(of: state.useSerifFont) { _, newValue in
                UserDefaults.standard.set(newValue, forKey: "useSerifFont")
            }
            .onChange(of: state.kerning) { _, newValue in
                UserDefaults.standard.set(newValue, forKey: "kerning")
            }
            .onChange(of: state.maxLines) { _, newValue in
                UserDefaults.standard.set(newValue, forKey: "maxLines")
            }
        
        let view3 = view2b
            #if os(iOS)
            .onChange(of: state.deviceOrientation) { oldOrientation, newOrientation in
                actions.handleOrientationChange(oldOrientation: oldOrientation, newOrientation: newOrientation)
            }
            #endif
            .task {
                actions.checkFirstLaunch()
            }

        return view3
    }
    
    func contentViewPlatformModifiers(
        state: ContentViewState,
        actions: ContentViewActions
    ) -> some View {
        let view1 = self
            .onAppear {
                actions.ensureDocumentExists()
            }

        let view2 = view1
            #if os(iOS)
            .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
                actions.undoLastChange()
            }
            #endif
            #if os(tvOS)
            .onPlayPauseCommand {
                state.isEditing.toggle()
            }
            .onExitCommand {
                state.showingOptionsMenu = true
            }
            #endif
            .onKeyPress(.escape) {
                actions.handleEscapeKey()
                return .handled
            }

        return view2
    }
    
    func contentViewBackgroundModifiers(theme: ColorTheme, colorScheme: ColorScheme) -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.backgroundColor(for: colorScheme))
    }
    
    func contentViewOverlayModifiers(
        state: ContentViewState,
        actions: ContentViewActions
    ) -> some View {
        let view1 = self
            #if os(macOS)
            .overlay(
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        state.isEditing.toggle()
                    }
                    .onTapGesture(count: 1, perform: {})
                    .highPriorityGesture(
                        TapGesture(count: 1)
                            .modifiers(.control)
                            .onEnded { _ in
                                state.showingOptionsMenu = true
                            }
                    )
                    .contextMenu {
                        Button("Options") {
                            state.showingOptionsMenu = true
                        }
                        Button("Edit Text") {
                            state.isEditing = true
                        }
                    }
                    .allowsHitTesting(!state.showingWelcomeView)
            )
            #elseif os(tvOS)
            .overlay(
                Color.clear
            )
            #else
            .overlay(
                TwoFingerTapView {
                    state.showingOptionsMenu = true
                } onOneFingerTap: {
                    state.isEditing.toggle()
                }
                .allowsHitTesting(!state.showingWelcomeView)
            )
            #endif

        return view1
    }
} 

struct HomeIndicatorModifier: ViewModifier {
    let isEditing: Bool
    
    func body(content: Content) -> some View {
        #if os(iOS)
        if isEditing {
            content
        } else {
            content
                .ignoresSafeArea(.container, edges: .bottom)
                .persistentSystemOverlays(.hidden)
        }
        #else
        content
        #endif
    }
} 

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
        
        // Settings persistence lives in ContentViewState's property observers,
        // so no .onChange mirroring is needed here.
        let view2 = view1
            #if os(iOS)
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                state.deviceOrientation = UIDevice.current.orientation
            }
            .onChange(of: state.deviceOrientation) { oldOrientation, newOrientation in
                actions.handleOrientationChange(oldOrientation: oldOrientation, newOrientation: newOrientation)
            }
            #endif
            .task {
                actions.checkFirstLaunch()
            }

        return view2
    }
    
    func contentViewPlatformModifiers(
        state: ContentViewState,
        actions: ContentViewActions
    ) -> some View {
        let view2 = self
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
                        Button { state.showingOptionsMenu = true } label: {
                            Label("Settings", systemImage: "slider.horizontal.3")
                        }
                        Button { state.isEditing = true } label: {
                            Label(LocalizationManager.editText, systemImage: "pencil")
                        }
                        Button { state.showingHelp = true } label: {
                            Label("Help", systemImage: "questionmark.circle")
                        }
                    }
                    .allowsHitTesting(!state.showingWelcomeView && !state.isEditing)
            )
            #elseif os(tvOS)
            .overlay(
                Color.clear
            )
            #elseif !os(visionOS)
            .overlay(
                TwoFingerTapView {
                    state.showingOptionsMenu = true
                } onOneFingerTap: {
                    state.isEditing.toggle()
                }
                .allowsHitTesting(!state.showingWelcomeView && !state.isEditing)
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

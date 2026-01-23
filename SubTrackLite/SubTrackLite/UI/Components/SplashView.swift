//
//  SplashView.swift
//  SubTrackLite
//
//  Premium launch animation
//

import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool
    @State private var size: Double = 0.8
    @State private var opacity: Double = 0.5
    @State private var logoScale: Double = 1.0
    @State private var textOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("splash_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .scaleEffect(logoScale)
                    .opacity(opacity)
                
                Text("UNSUB")
                    .font(DesignSystem.Typography.landingTitle())
                    .foregroundStyle(.white)
                    .tracking(8) // Wide letter spacing
                    .opacity(textOpacity)
                
                Text("FINANCIAL BODYGUARD")
                    .font(DesignSystem.Typography.caption())
                    .foregroundStyle(DesignSystem.Colors.tint)
                    .tracking(4)
                    .textCase(.uppercase)
                    .opacity(textOpacity)
            }
        }
        .onAppear {
            // Sequence of animations
            withAnimation(.easeIn(duration: 1.2)) {
                self.opacity = 1.0
                self.logoScale = 1.1
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
                self.textOpacity = 1.0
            }
            
            // Exit animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.isActive = false
                }
            }
        }
    }
}

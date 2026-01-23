//
//  SplashView.swift
//  SubTrackLite
//
//  Premium launch animation
//

import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "shield.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                
                Text(Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Unsub")
                    .font(DesignSystem.Typography.editorialLarge())
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
            }
            .scaleEffect(isActive ? 1.0 : 0.8)
            .opacity(isActive ? 1.0 : 0.0)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isActive = false
                }
            }
        }
    }
}

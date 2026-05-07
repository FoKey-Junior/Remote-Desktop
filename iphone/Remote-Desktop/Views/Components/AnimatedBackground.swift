// AnimatedBackground.swift
// Remote-Desktop
//
// Анимированный градиентный фон с медленно перемещающимися
// полупрозрачными сферами — основа glassmorphism / liquid glass дизайна.

import SwiftUI

struct AnimatedBackground: View {
    
    @State private var phase: CGFloat = 0
    @State private var offset1 = CGPoint(x: 0.3, y: 0.2)
    @State private var offset2 = CGPoint(x: 0.7, y: 0.6)
    @State private var offset3 = CGPoint(x: 0.5, y: 0.8)
    @State private var offset4 = CGPoint(x: 0.2, y: 0.5)
    @State private var offset5 = CGPoint(x: 0.8, y: 0.3)
    @State private var scale1: CGFloat = 1.0
    @State private var scale2: CGFloat = 1.0
    @State private var scale3: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack {
                // Глубокий тёмный фон
                Color(red: 0.03, green: 0.01, blue: 0.12)
                
                // Градиентный слой
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.02, blue: 0.20),
                        Color(red: 0.02, green: 0.06, blue: 0.16),
                        Color(red: 0.05, green: 0.01, blue: 0.14)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.8)
                
                // Сфера 1 — крупная фиолетовая
                GlowingSphere(
                    color: Color(red: 0.45, green: 0.1, blue: 0.85),
                    size: w * 0.85,
                    opacity: 0.4,
                    blurFactor: 0.2
                )
                .scaleEffect(scale1)
                .position(x: offset1.x * w, y: offset1.y * h)
                
                // Сфера 2 — голубая
                GlowingSphere(
                    color: Color(red: 0.1, green: 0.45, blue: 0.95),
                    size: w * 0.65,
                    opacity: 0.35,
                    blurFactor: 0.18
                )
                .scaleEffect(scale2)
                .position(x: offset2.x * w, y: offset2.y * h)
                
                // Сфера 3 — пурпурно-розовая
                GlowingSphere(
                    color: Color(red: 0.75, green: 0.15, blue: 0.55),
                    size: w * 0.55,
                    opacity: 0.3,
                    blurFactor: 0.18
                )
                .scaleEffect(scale3)
                .position(x: offset3.x * w, y: offset3.y * h)
                
                // Сфера 4 — бирюзовая
                GlowingSphere(
                    color: Color(red: 0.1, green: 0.8, blue: 0.65),
                    size: w * 0.4,
                    opacity: 0.2,
                    blurFactor: 0.15
                )
                .position(x: offset4.x * w, y: offset4.y * h)
                
                // Сфера 5 — золотистая (малая)
                GlowingSphere(
                    color: Color(red: 0.9, green: 0.6, blue: 0.2),
                    size: w * 0.3,
                    opacity: 0.15,
                    blurFactor: 0.12
                )
                .position(x: offset5.x * w, y: offset5.y * h)
                
                // Шумовой слой для текстуры
                Rectangle()
                    .fill(.white.opacity(0.008))
                    .blendMode(.overlay)
            }
            .ignoresSafeArea()
            .onAppear { startAnimations() }
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
            offset1 = CGPoint(x: 0.7, y: 0.7)
            scale1 = 1.15
        }
        withAnimation(.easeInOut(duration: 15).repeatForever(autoreverses: true)) {
            offset2 = CGPoint(x: 0.3, y: 0.3)
            scale2 = 0.9
        }
        withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
            offset3 = CGPoint(x: 0.6, y: 0.2)
            scale3 = 1.1
        }
        withAnimation(.easeInOut(duration: 13).repeatForever(autoreverses: true)) {
            offset4 = CGPoint(x: 0.8, y: 0.7)
        }
        withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
            offset5 = CGPoint(x: 0.2, y: 0.8)
        }
    }
}

// MARK: - Glowing Sphere

struct GlowingSphere: View {
    let color: Color
    let size: CGFloat
    let opacity: Double
    var blurFactor: CGFloat = 0.15
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(opacity),
                        color.opacity(opacity * 0.6),
                        color.opacity(opacity * 0.2),
                        color.opacity(0)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)
            .blur(radius: size * blurFactor)
    }
}

#Preview {
    AnimatedBackground()
}

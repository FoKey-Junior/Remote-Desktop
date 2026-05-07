// GlassCard.swift
// Remote-Desktop
//
// Переиспользуемые компоненты Liquid Glass.
// Полупрозрачный фон, размытие, многослойные границы,
// внутренние блики и мягкие тени.

import SwiftUI

// MARK: - Glass Card

/// Контейнер «жидкое стекло» с эффектом глубины и бликами
struct GlassCard<Content: View>: View {
    
    let cornerRadius: CGFloat
    let padding: CGFloat
    let content: () -> Content
    
    init(
        cornerRadius: CGFloat = 22,
        padding: CGFloat = 0,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(padding)
            .background(
                ZStack {
                    // Слой 1: тонкий материал
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                    
                    // Слой 2: цветной оверлей для глубины
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.08),
                                    .clear,
                                    .white.opacity(0.03)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Слой 3: верхний блик (light refraction)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.15),
                                    .white.opacity(0.0)
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .mask(
                            VStack {
                                Rectangle().frame(height: 60)
                                Spacer()
                            }
                        )
                    
                    // Слой 4: граница с градиентом (edge highlight)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.4),
                                    .white.opacity(0.08),
                                    .white.opacity(0.02),
                                    .white.opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.7
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            .shadow(color: .white.opacity(0.03), radius: 1, x: 0, y: -1)
    }
}

// MARK: - Glass Text Field

/// Текстовое поле в стиле Liquid Glass
struct GlassTextField: View {
    
    let placeholder: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(
                    isFocused
                    ? AnyShapeStyle(LinearGradient(
                        colors: [
                            Color(red: 0.5, green: 0.3, blue: 0.9),
                            Color(red: 0.3, green: 0.6, blue: 0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    : AnyShapeStyle(.white.opacity(0.5))
                )
                .frame(width: 24)
                .animation(.easeInOut(duration: 0.25), value: isFocused)
            
            if isSecure {
                SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.35)))
                    .foregroundStyle(.white)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($isFocused)
            } else {
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.35)))
                    .foregroundStyle(.white)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .focused($isFocused)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                
                // Внутренний блик
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(isFocused ? 0.08 : 0.04),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Граница — подсвечивается при фокусе
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        LinearGradient(
                            colors: isFocused
                            ? [Color(red: 0.5, green: 0.3, blue: 0.9).opacity(0.6),
                               Color(red: 0.3, green: 0.6, blue: 0.9).opacity(0.3)]
                            : [.white.opacity(0.18), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isFocused ? 1.0 : 0.6
                    )
            }
        )
        .shadow(color: isFocused ? Color(red: 0.4, green: 0.2, blue: 0.9).opacity(0.2) : .clear,
                radius: 12, x: 0, y: 4)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .animation(.easeInOut(duration: 0.25), value: isFocused)
    }
}

// MARK: - Glass Button

/// Кнопка в стиле Liquid Glass с внутренними бликами и анимацией
struct GlassButton: View {
    
    let title: String
    let icon: String?
    let gradient: [Color]
    let isLoading: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        title: String,
        icon: String? = nil,
        gradient: [Color] = [
            Color(red: 0.4, green: 0.2, blue: 0.9),
            Color(red: 0.6, green: 0.3, blue: 0.9)
        ],
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.gradient = gradient
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.9)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    // Основной градиент
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    // Стеклянный блик сверху
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.25),
                                    .white.opacity(0.05),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                    
                    // Нажатие — затемнение
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.black.opacity(isPressed ? 0.15 : 0))
                    
                    // Граница
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .white.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.6
                        )
                }
            )
            .shadow(color: gradient.first?.opacity(0.45) ?? .clear, radius: 16, x: 0, y: 8)
            .shadow(color: gradient.last?.opacity(0.2) ?? .clear, radius: 8, x: 0, y: 4)
        }
        .disabled(isLoading)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Glass Secondary Button (outlined)

/// Вторичная кнопка — только обводка, стеклянная
struct GlassSecondaryButton: View {
    
    let title: String
    let icon: String?
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white.opacity(0.8))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.white.opacity(isPressed ? 0.08 : 0.03))
                    
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .white.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.7
                        )
                }
            )
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Glass Divider

/// Разделитель в стиле glass — тонкая переливающаяся линия
struct GlassDivider: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        .white.opacity(0),
                        .white.opacity(0.15),
                        .white.opacity(0.15),
                        .white.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 0.5)
    }
}

// MARK: - Glass Badge

/// Значок / метка в стиле glass
struct GlassBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(color.opacity(0.3))
                    .overlay(
                        Capsule()
                            .stroke(color.opacity(0.4), lineWidth: 0.6)
                    )
            )
    }
}

// MARK: - Previews

#Preview("Glass Card") {
    ZStack {
        AnimatedBackground()
        VStack(spacing: 20) {
            GlassCard {
                Text("Liquid Glass Card")
                    .foregroundStyle(.white)
                    .padding(30)
            }
            
            GlassSecondaryButton(title: "Secondary", icon: "star.fill") {}
            
            GlassDivider()
                .padding(.horizontal, 40)
            
            GlassBadge(text: "LIVE", color: .green)
        }
        .padding()
    }
}

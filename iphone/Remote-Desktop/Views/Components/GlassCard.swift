// AppleComponents.swift
// Remote-Desktop
//
// Переиспользуемые UI-компоненты в стиле Apple.
// Чистый минимализм, системные цвета, нативные материалы.

import SwiftUI

// MARK: - Apple Text Field

/// Текстовое поле в стиле Apple Settings / Sign In
struct AppleTextField: View {
    
    let placeholder: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(isFocused ? AppStyle.accent : Color(.tertiaryLabel))
                .frame(width: 22)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textContentType(.password)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .focused($isFocused)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppStyle.radiusMedium))
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.radiusMedium)
                .stroke(
                    isFocused ? AppStyle.accent.opacity(0.5) : Color(.separator).opacity(0.5),
                    lineWidth: isFocused ? 1.5 : 0.5
                )
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        )
    }
}

// MARK: - Apple Primary Button

/// Основная кнопка действия в стиле Apple (filled)
struct ApplePrimaryButton: View {
    
    let title: String
    var icon: String? = nil
    var isLoading: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.85)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                    }
                    Text(title)
                        .font(.body.weight(.semibold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppStyle.accent)
            .clipShape(RoundedRectangle(cornerRadius: AppStyle.radiusMedium))
        }
        .buttonStyle(AppleFilledButtonStyle())
        .disabled(isLoading)
    }
}

// MARK: - Apple Secondary Button

/// Вторичная текстовая кнопка в стиле Apple
struct AppleSecondaryButton: View {
    
    let title: String
    var icon: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(AppStyle.accent)
        }
        .buttonStyle(AppleButtonStyle())
    }
}

// MARK: - Apple Card

/// Простая карточка с фоном и скруглением, без теней и бликов
struct AppleCard<Content: View>: View {
    
    var cornerRadius: CGFloat = AppStyle.radiusLarge
    let content: () -> Content
    
    init(
        cornerRadius: CGFloat = AppStyle.radiusLarge,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.content = content
    }
    
    var body: some View {
        content()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Command Icon View

/// Иконка команды в цветном круге (стиль Settings.app)
struct CommandIconView: View {
    
    let iconName: String
    let color: Color
    var size: CGFloat = 32
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: size * 0.44, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(color.gradient)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
    }
}

// MARK: - Previews

#Preview("Apple Components") {
    NavigationStack {
        List {
            Section {
                AppleTextField(
                    placeholder: "Email",
                    text: .constant(""),
                    icon: "envelope"
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            
            Section {
                ApplePrimaryButton(title: "Войти", icon: "arrow.right") {}
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            
            Section {
                HStack {
                    CommandIconView(iconName: "power", color: .red)
                    Text("Выключить ПК")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Preview")
    }
}

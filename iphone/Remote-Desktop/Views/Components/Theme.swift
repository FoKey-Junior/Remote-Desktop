// Theme.swift
// Remote-Desktop
//
// Единая дизайн-система приложения.
// Системные цвета iOS в стиле Apple Human Interface Guidelines.

import SwiftUI

// MARK: - App Design System

/// Минималистичная дизайн-система в стиле Apple.
/// Использует системные цвета iOS для автоматической адаптации Light / Dark.
enum AppStyle {
    
    // MARK: - Accent
    
    /// Единый акцентный цвет приложения
    static let accent = Color.blue
    
    // MARK: - Corner Radius
    
    /// Стандартные радиусы скругления
    static let radiusSmall: CGFloat = 8
    static let radiusMedium: CGFloat = 12
    static let radiusLarge: CGFloat = 16
    
    // MARK: - Spacing
    
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48
    
    // MARK: - Command Row Accents
    
    /// Цвета акцентов для разных типов команд
    static func commandAccent(for name: String) -> Color {
        let n = name.lowercased()
        if n.contains("выключ") && !n.contains("звук") { return .red }
        if n.contains("перезагру")                      { return .orange }
        if n.contains("блокир")                          { return .yellow }
        if n.contains("браузер") || n.contains("browser") { return .blue }
        if n.contains("скриншот") || n.contains("screenshot") { return .green }
        if n.contains("громкост") || n.contains("звук") { return .purple }
        return .blue
    }
    
    /// Иконка SF Symbols для команды
    static func commandIcon(for name: String) -> String {
        let n = name.lowercased()
        if n.contains("выключ") && !n.contains("звук")          { return "power" }
        if n.contains("перезагру")                               { return "arrow.clockwise" }
        if n.contains("блокир") || n.contains("замок")           { return "lock.fill" }
        if n.contains("браузер") || n.contains("browser")        { return "globe" }
        if n.contains("скриншот") || n.contains("screenshot")    { return "camera.viewfinder" }
        if n.contains("громкост") && n.contains("увелич")        { return "speaker.wave.3.fill" }
        if n.contains("громкост") && n.contains("уменьш")       { return "speaker.wave.1.fill" }
        if n.contains("звук")                                    { return "speaker.slash.fill" }
        if n.contains("пауз")                                    { return "pause.circle.fill" }
        if n.contains("плей") || n.contains("воспро")            { return "play.circle.fill" }
        return "terminal.fill"
    }
}

// MARK: - Apple Button Style

/// Стиль нажатия кнопки как в стандартных приложениях Apple
struct AppleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Стиль нажатия для filled-кнопок
struct AppleFilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

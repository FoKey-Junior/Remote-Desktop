// RemoteDesktopApp.swift
// Remote-Desktop
//
// Точка входа приложения Remote Desktop.
// Управляет навигацией между экранами авторизации и главным экраном
// на основе наличия JWT-токена.

import SwiftUI

@main
struct RemoteDesktopApp: App {
    
    // MARK: - Dependencies
    
    /// Сетевой сервис — по умолчанию используется Mock-реализация.
    /// Для подключения к реальному серверу замените на RealNetworkService().
    private let networkService: NetworkServiceProtocol = MockNetworkService()
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            RootView(networkService: networkService)
                .tint(.blue)
        }
    }
}

// MARK: - Root View

/// Корневой view, определяющий какой экран показать:
/// авторизацию или главный экран.
struct RootView: View {
    
    @AppStorage("jwt_token") private var token: String = ""
    let networkService: NetworkServiceProtocol
    
    var body: some View {
        Group {
            if token.isEmpty {
                AuthView(viewModel: AuthViewModel(networkService: networkService))
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                MainView(viewModel: MainViewModel(networkService: networkService))
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: token.isEmpty)
    }
}

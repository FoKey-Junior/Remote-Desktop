// MockNetworkService.swift
// Remote-Desktop
//
// Мок-реализация сетевого сервиса.
// Имитирует задержку сети и возвращает фейковые данные.
// Используется для автономной работы без сервера.

import Foundation

final class MockNetworkService: NetworkServiceProtocol {
    
    /// Имитация задержки сети (0.5–1.0 секунды)
    private func simulateNetworkDelay() async {
        let delay = UInt64.random(in: 500_000_000...1_000_000_000)
        try? await Task.sleep(nanoseconds: delay)
    }
    
    // MARK: - Auth
    
    func login(email: String, password: String) async throws -> String {
        await simulateNetworkDelay()
        
        guard !email.isEmpty, !password.isEmpty else {
            throw NetworkError.validationError("Email и пароль не могут быть пустыми")
        }
        
        guard password.count >= 8 else {
            throw NetworkError.validationError("Поле ввода должно содержать не менее 8 символов")
        }
        
        // Имитация JWT-токена
        return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXUyJ9.\(UUID().uuidString)"
    }
    
    func register(email: String, password: String) async throws -> String {
        await simulateNetworkDelay()
        
        guard !email.isEmpty, !password.isEmpty else {
            throw NetworkError.validationError("Email и пароль не могут быть пустыми")
        }
        
        guard email.contains("@") else {
            throw NetworkError.validationError("Введите в поле ввода действительный адрес электронной почты")
        }
        
        guard password.count >= 8 else {
            throw NetworkError.validationError("Поле ввода должно содержать не менее 8 символов")
        }
        
        return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXUyJ9.\(UUID().uuidString)"
    }
    
    // MARK: - Commands
    
    func sendCommand(token: String, command: String) async throws {
        await simulateNetworkDelay()
        
        guard !command.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NetworkError.validationError("Команда не может быть пустой")
        }
        
        // Имитация успешной отправки (201)
    }
    
    // MARK: - Health Check
    
    func checkServer() async throws -> Bool {
        await simulateNetworkDelay()
        return true
    }
}

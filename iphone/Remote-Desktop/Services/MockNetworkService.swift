// MockNetworkService.swift
// Remote-Desktop
//
// Мок-реализация сетевого сервиса.
// Имитирует задержку сети и возвращает фейковые данные.
// Используется по умолчанию для автономной работы без сервера.

import Foundation

final class MockNetworkService: NetworkServiceProtocol {
    
    // MARK: - Mock Storage
    
    /// Локальный массив команд — имитация серверного хранилища
    private var commands: [Command] = [
        Command(name: "Выключить ПК"),
        Command(name: "Перезагрузить ПК"),
        Command(name: "Заблокировать экран"),
        Command(name: "Открыть браузер"),
        Command(name: "Скриншот экрана"),
        Command(name: "Увеличить громкость"),
        Command(name: "Уменьшить громкость"),
        Command(name: "Выключить звук")
    ]
    
    /// Имитация задержки сети (0.8–1.5 секунды)
    private func simulateNetworkDelay() async {
        let delay = UInt64.random(in: 800_000_000...1_500_000_000)
        try? await Task.sleep(nanoseconds: delay)
    }
    
    // MARK: - Auth
    
    func login(email: String, password: String) async throws -> AuthResponse {
        await simulateNetworkDelay()
        
        // Простейшая валидация
        guard !email.isEmpty, !password.isEmpty else {
            throw NetworkError.serverError("Email и пароль не могут быть пустыми")
        }
        
        // Имитация успешного ответа с фейковым JWT-токеном
        let fakeToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.\(UUID().uuidString)"
        return AuthResponse(
            token: fakeToken,
            message: "Вход выполнен успешно"
        )
    }
    
    func register(email: String, password: String) async throws -> AuthResponse {
        await simulateNetworkDelay()
        
        guard !email.isEmpty, !password.isEmpty else {
            throw NetworkError.serverError("Email и пароль не могут быть пустыми")
        }
        
        guard password.count >= 6 else {
            throw NetworkError.serverError("Пароль должен быть не менее 6 символов")
        }
        
        let fakeToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.\(UUID().uuidString)"
        return AuthResponse(
            token: fakeToken,
            message: "Регистрация прошла успешно"
        )
    }
    
    // MARK: - Commands
    
    func fetchCommands() async throws -> [Command] {
        await simulateNetworkDelay()
        return commands
    }
    
    func addCommand(name: String) async throws -> Command {
        await simulateNetworkDelay()
        
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NetworkError.serverError("Название команды не может быть пустым")
        }
        
        let newCommand = Command(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
        commands.append(newCommand)
        return newCommand
    }
    
    func executeCommand(_ command: Command) async throws -> CommandExecutionResponse {
        await simulateNetworkDelay()
        return CommandExecutionResponse(
            success: true,
            message: "Команда «\(command.name)» выполнена успешно"
        )
    }
}

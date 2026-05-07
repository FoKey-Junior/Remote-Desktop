// Models.swift
// Remote-Desktop
//
// Модели данных приложения.

import Foundation

// MARK: - Auth Models

/// Запрос на авторизацию / регистрацию
struct AuthRequest: Codable {
    let email: String
    let password: String
}

/// Ответ сервера после успешной авторизации / регистрации
struct AuthResponse: Codable {
    let token: String
    let message: String
}

// MARK: - Command Models

/// Команда для удалённого управления ПК
struct Command: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

/// Запрос на добавление новой команды
struct AddCommandRequest: Codable {
    let name: String
}

/// Запрос на выполнение команды
struct ExecuteCommandRequest: Codable {
    let commandId: String
}

/// Ответ сервера при выполнении команды
struct CommandExecutionResponse: Codable {
    let success: Bool
    let message: String
}

/// Ответ сервера со списком команд
struct CommandsListResponse: Codable {
    let commands: [Command]
}

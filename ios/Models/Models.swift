// Models.swift
// Remote-Desktop
//
// Модели данных приложения.
// Соответствуют контракту C++ Crow API сервера.

import Foundation

// MARK: - Auth Request

/// Запрос на авторизацию / регистрацию.
/// Сервер ожидает JSON: {"email":"...","password":"..."}
struct AuthRequest: Codable {
    let email: String
    let password: String
}

// MARK: - Command Request

/// Запрос на отправку команды на сервер.
/// Сервер ожидает JSON: {"token":"...","command":"..."}
struct CommandRequest: Codable {
    let token: String
    let command: String
}

// MARK: - Token Request

/// Запрос с токеном (для get_command / delete_command).
/// Сервер ожидает JSON: {"token":"..."}
struct TokenRequest: Codable {
    let token: String
}

// MARK: - Sent Command (Local History)

/// Локальная модель для истории отправленных команд.
/// Хранится только на устройстве (сервер не хранит историю).
struct SentCommand: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let date: Date
    let status: CommandStatus
    
    init(id: UUID = UUID(), text: String, date: Date = Date(), status: CommandStatus = .sent) {
        self.id = id
        self.text = text
        self.date = date
        self.status = status
    }
    
    enum CommandStatus: String, Codable {
        case sent      // Успешно отправлена
        case failed    // Ошибка отправки
        case sending   // В процессе отправки
    }
}

// MARK: - Quick Command

/// Предустановленная быстрая команда для UI
struct QuickCommand: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let command: String
    let icon: String
    let color: String // Имя цвета для использования в SwiftUI
}

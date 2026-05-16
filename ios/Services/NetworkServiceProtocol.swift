// NetworkServiceProtocol.swift
// Remote-Desktop
//
// Протокол сетевого сервиса.
// Определяет контракт для всех реализаций (Mock и Real).
// Соответствует API сервера: plain text ответы, token в body.

import Foundation

// MARK: - Network Service Protocol

/// Протокол, описывающий все сетевые операции приложения.
/// Каждая реализация (Mock / Real) должна поддерживать все методы.
protocol NetworkServiceProtocol {
    
    /// Авторизация пользователя
    /// - Parameters:
    ///   - email: Email пользователя
    ///   - password: Пароль
    /// - Returns: JWT-токен (plain text строка от сервера)
    func login(email: String, password: String) async throws -> String
    
    /// Регистрация нового пользователя
    /// - Parameters:
    ///   - email: Email пользователя
    ///   - password: Пароль
    /// - Returns: JWT-токен (plain text строка от сервера)
    func register(email: String, password: String) async throws -> String
    
    /// Отправка команды на сервер для удалённого ПК
    /// - Parameters:
    ///   - token: JWT-токен авторизации
    ///   - command: Текст команды
    func sendCommand(token: String, command: String) async throws
    
    /// Проверка связи с сервером (GET /api)
    /// - Returns: true если сервер доступен
    func checkServer() async throws -> Bool
}

// MARK: - Network Errors

/// Ошибки сетевого сервиса
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case conflict(String)
    case validationError(String)
    case notFound(String)
    case serverError(String)
    case connectionFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL-адрес"
        case .invalidResponse:
            return "Некорректный ответ сервера"
        case .unauthorized:
            return "Неверный email или пароль"
        case .conflict(let message):
            return message
        case .validationError(let message):
            return message
        case .notFound(let message):
            return message
        case .serverError(let message):
            return "Ошибка сервера: \(message)"
        case .connectionFailed:
            return "Не удалось подключиться к серверу"
        case .unknown:
            return "Неизвестная ошибка"
        }
    }
}

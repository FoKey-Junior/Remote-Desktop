// NetworkServiceProtocol.swift
// Remote-Desktop
//
// Протокол сетевого сервиса.
// Определяет контракт для всех реализаций (Mock и Real).

import Foundation

// MARK: - Network Service Protocol

/// Протокол, описывающий все сетевые операции приложения.
/// Каждая реализация (Mock / Real) должна поддерживать все методы.
protocol NetworkServiceProtocol {
    
    /// Авторизация пользователя
    /// - Parameters:
    ///   - email: Email или логин пользователя
    ///   - password: Пароль
    /// - Returns: Ответ с JWT-токеном
    func login(email: String, password: String) async throws -> AuthResponse
    
    /// Регистрация нового пользователя
    /// - Parameters:
    ///   - email: Email или логин
    ///   - password: Пароль
    /// - Returns: Ответ с JWT-токеном
    func register(email: String, password: String) async throws -> AuthResponse
    
    /// Получение списка доступных команд
    /// - Returns: Массив команд
    func fetchCommands() async throws -> [Command]
    
    /// Добавление новой команды
    /// - Parameter name: Название команды
    /// - Returns: Созданная команда
    func addCommand(name: String) async throws -> Command
    
    /// Выполнение команды на удалённом ПК
    /// - Parameter command: Команда для выполнения
    /// - Returns: Результат выполнения
    func executeCommand(_ command: Command) async throws -> CommandExecutionResponse
}

// MARK: - Network Errors

/// Ошибки сетевого сервиса
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(String)
    case decodingError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL-адрес"
        case .invalidResponse:
            return "Некорректный ответ сервера"
        case .unauthorized:
            return "Необходима авторизация"
        case .serverError(let message):
            return "Ошибка сервера: \(message)"
        case .decodingError:
            return "Ошибка обработки данных"
        case .unknown:
            return "Неизвестная ошибка"
        }
    }
}

// RealNetworkService.swift
// Remote-Desktop
//
// Реальная реализация сетевого сервиса.
// Использует URLSession с async/await.
// КРИТИЧНО: Все запросы — POST с JSON в httpBody.
// JWT-токен автоматически подставляется в заголовок Authorization.

import Foundation
import SwiftUI

final class RealNetworkService: NetworkServiceProtocol {
    
    // MARK: - Configuration
    
    // ⚠️ ЗАМЕНИТЕ НА РЕАЛЬНЫЙ URL ВАШЕГО СЕРВЕРА
    private let baseURL = "YOUR_API_URL_HERE"
    
    // Endpoints — замените на ваши реальные пути
    private enum Endpoints {
        static let login = "/api/auth/login"
        static let register = "/api/auth/register"
        static let fetchCommands = "/api/commands/list"
        static let addCommand = "/api/commands/add"
        static let executeCommand = "/api/commands/execute"
    }
    
    // MARK: - Token Access
    
    /// Получение JWT-токена из @AppStorage (UserDefaults)
    private var token: String {
        UserDefaults.standard.string(forKey: "jwt_token") ?? ""
    }
    
    // MARK: - URLSession
    
    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Private Helpers
    
    /// Создание POST-запроса с JSON-телом и опциональной авторизацией
    /// - Parameters:
    ///   - endpoint: Путь API
    ///   - body: Encodable-объект для сериализации в JSON
    ///   - authorized: Нужно ли добавлять JWT-токен
    /// - Returns: Готовый URLRequest
    private func makePostRequest<T: Encodable>(
        endpoint: String,
        body: T,
        authorized: Bool = true
    ) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Автоматическая подстановка JWT-токена
        if authorized {
            let currentToken = token
            guard !currentToken.isEmpty else {
                throw NetworkError.unauthorized
            }
            request.setValue("Bearer \(currentToken)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = try encoder.encode(body)
        return request
    }
    
    /// Выполнение запроса и декодирование ответа
    /// - Parameter request: URLRequest
    /// - Returns: Декодированный объект
    private func perform<R: Decodable>(_ request: URLRequest) async throws -> R {
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try decoder.decode(R.self, from: data)
            } catch {
                throw NetworkError.decodingError
            }
        case 401:
            throw NetworkError.unauthorized
        default:
            // Попытка извлечь сообщение об ошибке из ответа
            if let errorBody = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorBody["message"] as? String {
                throw NetworkError.serverError(message)
            }
            throw NetworkError.serverError("HTTP \(httpResponse.statusCode)")
        }
    }
    
    // MARK: - Auth (POST, без авторизации)
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let body = AuthRequest(email: email, password: password)
        let request = try makePostRequest(endpoint: Endpoints.login, body: body, authorized: false)
        return try await perform(request)
    }
    
    func register(email: String, password: String) async throws -> AuthResponse {
        let body = AuthRequest(email: email, password: password)
        let request = try makePostRequest(endpoint: Endpoints.register, body: body, authorized: false)
        return try await perform(request)
    }
    
    // MARK: - Commands (POST, с авторизацией)
    
    func fetchCommands() async throws -> [Command] {
        // POST-запрос с пустым телом для получения списка команд
        let body: [String: String] = [:]  // Пустое тело
        let request = try makePostRequest(endpoint: Endpoints.fetchCommands, body: body, authorized: true)
        let response: CommandsListResponse = try await perform(request)
        return response.commands
    }
    
    func addCommand(name: String) async throws -> Command {
        let body = AddCommandRequest(name: name)
        let request = try makePostRequest(endpoint: Endpoints.addCommand, body: body, authorized: true)
        return try await perform(request)
    }
    
    func executeCommand(_ command: Command) async throws -> CommandExecutionResponse {
        let body = ExecuteCommandRequest(commandId: command.id.uuidString)
        let request = try makePostRequest(endpoint: Endpoints.executeCommand, body: body, authorized: true)
        return try await perform(request)
    }
}

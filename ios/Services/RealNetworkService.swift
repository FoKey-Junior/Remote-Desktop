// RealNetworkService.swift
// Remote-Desktop
//
// Реальная реализация сетевого сервиса.
// Работает с C++ Crow API сервером.
//
// ВАЖНО:
// - Сервер возвращает plain text (не JSON)
// - JWT-токен передаётся в JSON body (не в Authorization header)
// - Все запросы — POST с JSON body (кроме /api — GET)

import Foundation

final class RealNetworkService: NetworkServiceProtocol {
    
    // MARK: - Configuration
    
    /// Базовый URL сервера. По умолчанию localhost:4000.
    private let baseURL: String
    
    // MARK: - Endpoints
    
    private enum Endpoints {
        static let healthCheck = "/api"
        static let registration = "/api/registration"
        static let authorization = "/api/authorization"
        static let newCommand = "/api/new_command"
    }
    
    // MARK: - URLSession
    
    private let session: URLSession
    private let encoder = JSONEncoder()
    
    init(baseURL: String = "http://localhost:4000") {
        self.baseURL = baseURL
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Auth
    
    func login(email: String, password: String) async throws -> String {
        let body = AuthRequest(email: email, password: password)
        let request = try makePostRequest(endpoint: Endpoints.authorization, body: body)
        
        let (data, response) = try await performRequest(request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        let responseText = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        switch statusCode {
        case 200:
            guard !responseText.isEmpty else { throw NetworkError.invalidResponse }
            return responseText
        case 400:
            throw NetworkError.validationError(responseText.isEmpty ? "Неверные данные" : responseText)
        case 401:
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.notFound(responseText.isEmpty ? "Пользователь не найден" : responseText)
        case 422:
            throw NetworkError.validationError(responseText.isEmpty ? "Ошибка валидации" : responseText)
        default:
            throw NetworkError.serverError("HTTP \(statusCode)")
        }
    }
    
    func register(email: String, password: String) async throws -> String {
        let body = AuthRequest(email: email, password: password)
        let request = try makePostRequest(endpoint: Endpoints.registration, body: body)
        
        let (data, response) = try await performRequest(request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        let responseText = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        switch statusCode {
        case 200:
            guard !responseText.isEmpty else { throw NetworkError.invalidResponse }
            return responseText
        case 400:
            throw NetworkError.validationError(responseText.isEmpty ? "Неверные данные" : responseText)
        case 409:
            throw NetworkError.conflict(responseText.isEmpty ? "Пользователь уже существует" : responseText)
        case 422:
            throw NetworkError.validationError(responseText.isEmpty ? "Ошибка валидации" : responseText)
        default:
            throw NetworkError.serverError("HTTP \(statusCode)")
        }
    }
    
    // MARK: - Commands
    
    func sendCommand(token: String, command: String) async throws {
        let body = CommandRequest(token: token, command: command)
        let request = try makePostRequest(endpoint: Endpoints.newCommand, body: body)
        
        let (_, response) = try await performRequest(request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        
        switch statusCode {
        case 201:
            return // Успешно
        case 400:
            throw NetworkError.validationError("Неверные данные запроса")
        case 500:
            throw NetworkError.serverError("Не удалось сохранить команду")
        default:
            throw NetworkError.serverError("HTTP \(statusCode)")
        }
    }
    
    // MARK: - Health Check
    
    func checkServer() async throws -> Bool {
        guard let url = URL(string: baseURL + Endpoints.healthCheck) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5
        
        let (_, response) = try await session.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        return statusCode == 200
    }
    
    // MARK: - Private Helpers
    
    /// Создание POST-запроса с JSON-телом.
    /// Токен НЕ передаётся через Authorization header —
    /// он включается в JSON body (для эндпоинтов, которые его требуют).
    private func makePostRequest<T: Encodable>(
        endpoint: String,
        body: T
    ) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        return request
    }
    
    /// Выполнение запроса с обработкой сетевых ошибок
    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .cannotConnectToHost, .timedOut, .cannotFindHost:
                throw NetworkError.connectionFailed
            default:
                throw NetworkError.unknown
            }
        }
    }
}

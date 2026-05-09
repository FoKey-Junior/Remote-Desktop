// AuthViewModel.swift
// Remote-Desktop
//
// ViewModel для экрана авторизации / регистрации.
// Управляет состоянием формы, валидацией и вызовами NetworkService.

import Foundation
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    // MARK: - Dependencies
    
    private let networkService: NetworkServiceProtocol
    @AppStorage("jwt_token") private var token: String = ""
    
    // MARK: - Init
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    // MARK: - Validation
    
    var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty
    }
    
    // MARK: - Actions
    
    /// Выполнить вход
    func login() {
        guard isFormValid else {
            showErrorMessage("Заполните все поля")
            return
        }
        
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let response = try await networkService.login(
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password
                )
                token = response.token
            } catch {
                showErrorMessage(error.localizedDescription)
            }
        }
    }
    
    /// Выполнить регистрацию
    func register() {
        guard isFormValid else {
            showErrorMessage("Заполните все поля")
            return
        }
        
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let response = try await networkService.register(
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password
                )
                token = response.token
            } catch {
                showErrorMessage(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Private
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}

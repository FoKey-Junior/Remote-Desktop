// MainViewModel.swift
// Remote-Desktop
//
// ViewModel для главного экрана.
// Управляет списком команд, добавлением и выполнением команд.

import Foundation
import SwiftUI

@MainActor
final class MainViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var commands: [Command] = []
    @Published var isLoading: Bool = false
    @Published var isExecuting: Bool = false
    @Published var newCommandName: String = ""
    @Published var showAddSheet: Bool = false
    @Published var isAddingCommand: Bool = false
    
    /// Сообщение для Alert
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    
    /// Название текущей выполняемой команды (для лоадера)
    @Published var executingCommandName: String = ""
    
    // MARK: - Dependencies
    
    private let networkService: NetworkServiceProtocol
    @AppStorage("jwt_token") private var token: String = ""
    
    // MARK: - Init
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    // MARK: - Actions
    
    /// Загрузить список команд
    func loadCommands() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                commands = try await networkService.fetchCommands()
            } catch {
                showAlertMessage("Ошибка загрузки: \(error.localizedDescription)")
            }
        }
    }
    
    /// Добавить новую команду
    func addCommand() {
        let name = newCommandName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        
        Task {
            isAddingCommand = true
            defer { isAddingCommand = false }
            
            do {
                let command = try await networkService.addCommand(name: name)
                commands.append(command)
                newCommandName = ""
                showAddSheet = false
            } catch {
                showAlertMessage("Ошибка: \(error.localizedDescription)")
            }
        }
    }
    
    /// Выполнить команду
    func executeCommand(_ command: Command) {
        Task {
            executingCommandName = command.name
            isExecuting = true
            defer { isExecuting = false }
            
            do {
                let response = try await networkService.executeCommand(command)
                showAlertMessage(response.message)
            } catch {
                showAlertMessage("Ошибка: \(error.localizedDescription)")
            }
        }
    }
    
    /// Выйти из аккаунта
    func logout() {
        token = ""
    }
    
    // MARK: - Private
    
    private func showAlertMessage(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}

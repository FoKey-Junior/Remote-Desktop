// MainViewModel.swift
// Remote-Desktop
//
// ViewModel для главного экрана.
// Управляет отправкой команд, историей и проверкой связи с сервером.

import Foundation
import SwiftUI

@MainActor
final class MainViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Текст команды для отправки
    @Published var commandText: String = ""
    
    /// Отправка в процессе
    @Published var isSending: Bool = false
    
    /// Статус подключения к серверу
    @Published var isConnected: Bool = false
    @Published var isCheckingConnection: Bool = false
    
    /// Локальная история отправленных команд
    @Published var sentHistory: [SentCommand] = []
    
    /// Сообщение для Alert
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    
    /// Успешная отправка (для анимации)
    @Published var showSuccessToast: Bool = false
    @Published var successMessage: String = ""
    
    // MARK: - Quick Commands
    
    let quickCommands: [QuickCommand] = [
        QuickCommand(name: "Выключить", command: "shutdown /s /t 0", icon: "power", color: "red"),
        QuickCommand(name: "Перезагрузка", command: "shutdown /r /t 0", icon: "arrow.clockwise", color: "orange"),
        QuickCommand(name: "Блокировка", command: "rundll32.exe user32.dll,LockWorkStation", icon: "lock.fill", color: "yellow"),
        QuickCommand(name: "Скриншот", command: "screenshot", icon: "camera.viewfinder", color: "green"),
        QuickCommand(name: "Громкость +", command: "volume_up", icon: "speaker.wave.3.fill", color: "purple"),
        QuickCommand(name: "Громкость −", command: "volume_down", icon: "speaker.wave.1.fill", color: "purple"),
        QuickCommand(name: "Без звука", command: "volume_mute", icon: "speaker.slash.fill", color: "gray"),
        QuickCommand(name: "Браузер", command: "start chrome", icon: "globe", color: "blue"),
    ]
    
    // MARK: - Dependencies
    
    private let networkService: NetworkServiceProtocol
    @AppStorage("jwt_token") private var token: String = ""
    
    // MARK: - UserDefaults Key
    
    private let historyKey = "sent_commands_history"
    private let maxHistoryCount = 50
    
    // MARK: - Init
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
        loadHistory()
    }
    
    // MARK: - Actions
    
    /// Отправить произвольную команду
    func sendCommand() {
        let text = commandText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        sendCommandText(text)
        commandText = ""
    }
    
    /// Отправить быструю команду
    func sendQuickCommand(_ quick: QuickCommand) {
        sendCommandText(quick.command)
    }
    
    /// Отправить текст команды на сервер
    func sendCommandText(_ text: String) {
        // Добавляем в историю со статусом "sending"
        let command = SentCommand(text: text, status: .sending)
        sentHistory.insert(command, at: 0)
        
        Task {
            isSending = true
            defer { isSending = false }
            
            do {
                try await networkService.sendCommand(token: token, command: text)
                
                // Обновить статус на "sent"
                if let index = sentHistory.firstIndex(where: { $0.id == command.id }) {
                    sentHistory[index] = SentCommand(
                        id: command.id,
                        text: command.text,
                        date: command.date,
                        status: .sent
                    )
                }
                
                // Показать toast
                successMessage = "«\(text)» отправлена"
                showSuccessToast = true
                
                // Скрыть toast через 2 секунды
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    self?.showSuccessToast = false
                }
                
                saveHistory()
                
            } catch {
                // Обновить статус на "failed"
                if let index = sentHistory.firstIndex(where: { $0.id == command.id }) {
                    sentHistory[index] = SentCommand(
                        id: command.id,
                        text: command.text,
                        date: command.date,
                        status: .failed
                    )
                }
                saveHistory()
                showAlertMessage("Ошибка: \(error.localizedDescription)")
            }
        }
    }
    
    /// Проверить подключение к серверу
    func checkConnection() {
        Task {
            isCheckingConnection = true
            defer { isCheckingConnection = false }
            
            do {
                isConnected = try await networkService.checkServer()
            } catch {
                isConnected = false
            }
        }
    }
    
    /// Очистить историю
    func clearHistory() {
        sentHistory.removeAll()
        saveHistory()
    }
    
    /// Выйти из аккаунта
    func logout() {
        token = ""
        sentHistory.removeAll()
        UserDefaults.standard.removeObject(forKey: historyKey)
    }
    
    // MARK: - Persistence
    
    private func saveHistory() {
        // Ограничиваем размер истории
        if sentHistory.count > maxHistoryCount {
            sentHistory = Array(sentHistory.prefix(maxHistoryCount))
        }
        
        if let data = try? JSONEncoder().encode(sentHistory) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }
    
    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let history = try? JSONDecoder().decode([SentCommand].self, from: data) else {
            return
        }
        sentHistory = history
    }
    
    // MARK: - Private
    
    private func showAlertMessage(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}

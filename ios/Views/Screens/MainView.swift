// MainView.swift
// Remote-Desktop
//
// Главный экран приложения (для авторизованных пользователей).
// Интерфейс отправки команд на удалённый ПК через API.
// Нативный Apple-дизайн.

import SwiftUI

struct MainView: View {
    
    @StateObject var viewModel: MainViewModel
    @State private var appearAnimation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        // Статус подключения
                        connectionStatusSection
                        
                        // Поле ввода команды
                        commandInputSection
                            .padding(.top, AppStyle.spacingM)
                        
                        // Быстрые команды
                        quickCommandsSection
                            .padding(.top, AppStyle.spacingL)
                        
                        // История
                        historySection
                            .padding(.top, AppStyle.spacingL)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, AppStyle.spacingM)
                }
                
                // Toast успешной отправки
                if viewModel.showSuccessToast {
                    VStack {
                        Spacer()
                        successToast
                            .padding(.bottom, 30)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showSuccessToast)
                }
            }
            .navigationTitle("Remote Desktop")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            viewModel.clearHistory()
                        } label: {
                            Label("Очистить историю", systemImage: "trash")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            withAnimation {
                                viewModel.logout()
                            }
                        } label: {
                            Label("Выйти", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                }
            }
        }
        .onAppear {
            viewModel.checkConnection()
            withAnimation(.easeOut(duration: 0.4)) {
                appearAnimation = true
            }
        }
        .alert("Ошибка", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }
    
    // MARK: - Connection Status
    
    private var connectionStatusSection: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(viewModel.isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)
                .shadow(color: viewModel.isConnected ? .green.opacity(0.5) : .red.opacity(0.5), radius: 4)
            
            Text(viewModel.isConnected ? "Сервер доступен" : "Нет подключения")
                .font(.subheadline)
                .foregroundStyle(Color(.secondaryLabel))
            
            Spacer()
            
            if viewModel.isCheckingConnection {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Button {
                    viewModel.checkConnection()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppStyle.accent)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppStyle.radiusMedium))
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : -10)
    }
    
    // MARK: - Command Input
    
    private var commandInputSection: some View {
        VStack(spacing: AppStyle.spacingS) {
            Text("Отправить команду")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(.secondaryLabel))
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 4)
            
            HStack(spacing: 10) {
                Image(systemName: "terminal")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(.tertiaryLabel))
                    .frame(width: 22)
                
                TextField("Введите команду...", text: $viewModel.commandText)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.send)
                    .onSubmit {
                        viewModel.sendCommand()
                    }
                
                // Кнопка отправки
                Button {
                    viewModel.sendCommand()
                } label: {
                    Group {
                        if viewModel.isSending {
                            ProgressView()
                                .scaleEffect(0.75)
                                .tint(.white)
                        } else {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        viewModel.commandText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color(.tertiaryLabel)
                            : AppStyle.accent
                    )
                    .clipShape(Circle())
                }
                .disabled(viewModel.commandText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSending)
                .animation(.easeInOut(duration: 0.2), value: viewModel.commandText.isEmpty)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppStyle.radiusMedium))
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 10)
    }
    
    // MARK: - Quick Commands
    
    private var quickCommandsSection: some View {
        VStack(spacing: AppStyle.spacingS) {
            Text("Быстрые команды")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(.secondaryLabel))
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 4)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ], spacing: 10) {
                ForEach(Array(viewModel.quickCommands.enumerated()), id: \.element.id) { index, quick in
                    QuickCommandButton(quick: quick) {
                        viewModel.sendQuickCommand(quick)
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(
                        .easeOut(duration: 0.3).delay(Double(index) * 0.05),
                        value: appearAnimation
                    )
                }
            }
        }
    }
    
    // MARK: - History
    
    private var historySection: some View {
        VStack(spacing: AppStyle.spacingS) {
            if !viewModel.sentHistory.isEmpty {
                HStack {
                    Text("История")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color(.secondaryLabel))
                        .textCase(.uppercase)
                    
                    Spacer()
                    
                    Text("\(viewModel.sentHistory.count)")
                        .font(.footnote)
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                .padding(.leading, 4)
                
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.sentHistory.enumerated()), id: \.element.id) { index, command in
                        if index > 0 {
                            Divider()
                                .padding(.leading, 44)
                        }
                        HistoryRow(command: command)
                    }
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: AppStyle.radiusMedium))
            }
        }
    }
    
    // MARK: - Success Toast
    
    private var successToast: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.system(size: 18))
            
            Text(viewModel.successMessage)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color(.label))
                .lineLimit(1)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(.regularMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}

// MARK: - Quick Command Button

struct QuickCommandButton: View {
    
    let quick: QuickCommand
    let action: () -> Void
    
    private var color: Color {
        switch quick.color {
        case "red":    return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green":  return .green
        case "blue":   return .blue
        case "purple": return .purple
        case "gray":   return Color(.systemGray)
        default:       return .blue
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                CommandIconView(
                    iconName: quick.icon,
                    color: color,
                    size: 30
                )
                
                Text(quick.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color(.label))
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppStyle.radiusMedium))
        }
        .buttonStyle(AppleButtonStyle())
    }
}

// MARK: - History Row

struct HistoryRow: View {
    
    let command: SentCommand
    
    private var statusIcon: String {
        switch command.status {
        case .sent:    return "checkmark.circle.fill"
        case .failed:  return "xmark.circle.fill"
        case .sending: return "arrow.up.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch command.status {
        case .sent:    return .green
        case .failed:  return .red
        case .sending: return .orange
        }
    }
    
    private var timeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: command.date, relativeTo: Date())
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: statusIcon)
                .font(.system(size: 18))
                .foregroundStyle(statusColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(command.text)
                    .font(.subheadline)
                    .foregroundStyle(Color(.label))
                    .lineLimit(1)
                
                Text(timeString)
                    .font(.caption2)
                    .foregroundStyle(Color(.tertiaryLabel))
            }
            
            Spacer()
            
            if command.status == .sending {
                ProgressView()
                    .scaleEffect(0.7)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

// MARK: - Previews

#Preview {
    MainView(viewModel: MainViewModel(networkService: MockNetworkService()))
}

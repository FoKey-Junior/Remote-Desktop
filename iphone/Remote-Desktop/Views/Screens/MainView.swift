// MainView.swift
// Remote-Desktop
//
// Главный экран приложения (для авторизованных пользователей).
// Список команд в стиле Apple Settings / Home.
// Нативный List с insetGrouped стилем.

import SwiftUI

struct MainView: View {
    
    @StateObject var viewModel: MainViewModel
    @State private var appearAnimation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                mainContent
                
                // Оверлей выполнения команды
                if viewModel.isExecuting {
                    executingOverlay
                }
            }
            .navigationTitle("Команды")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            viewModel.logout()
                        }
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadCommands()
            withAnimation(.easeOut(duration: 0.4)) {
                appearAnimation = true
            }
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddCommandSheet(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .alert("Результат", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }
    
    // MARK: - Main Content
    
    @ViewBuilder
    private var mainContent: some View {
        if viewModel.isLoading && viewModel.commands.isEmpty {
            loadingView
        } else if viewModel.commands.isEmpty {
            emptyStateView
        } else {
            commandListView
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 14) {
            ProgressView()
                .scaleEffect(1.1)
            Text("Загрузка...")
                .font(.subheadline)
                .foregroundStyle(Color(.secondaryLabel))
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(Color(.tertiaryLabel))
            
            Text("Нет команд")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color(.secondaryLabel))
            
            Text("Нажмите «+» чтобы добавить\nпервую команду")
                .font(.subheadline)
                .foregroundStyle(Color(.tertiaryLabel))
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 60)
    }
    
    // MARK: - Command List
    
    private var commandListView: some View {
        List {
            Section {
                ForEach(Array(viewModel.commands.enumerated()), id: \.element.id) { index, command in
                    CommandRow(command: command) {
                        viewModel.executeCommand(command)
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(
                        .easeOut(duration: 0.3).delay(Double(index) * 0.04),
                        value: appearAnimation
                    )
                }
            } header: {
                HStack {
                    Text("\(viewModel.commands.count) команд")
                        .textCase(.none)
                    Spacer()
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 7, height: 7)
                        Text("Онлайн")
                            .font(.caption)
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Executing Overlay
    
    private var executingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .transition(.opacity)
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.3)
                    .tint(AppStyle.accent)
                
                Text("Выполняется...")
                    .font(.headline)
                    .foregroundStyle(Color(.label))
                
                Text(viewModel.executingCommandName)
                    .font(.subheadline)
                    .foregroundStyle(Color(.secondaryLabel))
            }
            .padding(AppStyle.spacingXL)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppStyle.radiusLarge))
            .transition(.scale(scale: 0.9).combined(with: .opacity))
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.isExecuting)
    }
}

// MARK: - Command Row

struct CommandRow: View {
    
    let command: Command
    let onTap: () -> Void
    
    private var accentColor: Color {
        AppStyle.commandAccent(for: command.name)
    }
    
    private var iconName: String {
        AppStyle.commandIcon(for: command.name)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Иконка в цветном квадрате (как в Settings.app)
                CommandIconView(
                    iconName: iconName,
                    color: accentColor
                )
                
                // Название команды
                VStack(alignment: .leading, spacing: 2) {
                    Text(command.name)
                        .font(.body)
                        .foregroundStyle(Color(.label))
                        .lineLimit(1)
                    
                    Text("Нажмите для выполнения")
                        .font(.caption)
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                
                Spacer()
                
                Image(systemName: "play.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(.tertiaryLabel))
            }
        }
        .buttonStyle(AppleButtonStyle())
    }
}

// MARK: - Add Command Sheet

struct AddCommandSheet: View {
    
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: AppStyle.spacingL) {
                    // Иконка
                    Image(systemName: "plus.rectangle.on.rectangle")
                        .font(.system(size: 40, weight: .thin))
                        .foregroundStyle(AppStyle.accent)
                        .padding(.top, AppStyle.spacingM)
                    
                    Text("Введите название команды для ПК")
                        .font(.subheadline)
                        .foregroundStyle(Color(.secondaryLabel))
                    
                    // Поле ввода
                    AppleTextField(
                        placeholder: "Название команды",
                        text: $viewModel.newCommandName,
                        icon: "terminal"
                    )
                    .padding(.horizontal, AppStyle.spacingM)
                    
                    // Кнопка добавления
                    ApplePrimaryButton(
                        title: "Добавить",
                        icon: "plus",
                        isLoading: viewModel.isAddingCommand
                    ) {
                        viewModel.addCommand()
                    }
                    .padding(.horizontal, AppStyle.spacingM)
                    
                    Spacer()
                }
            }
            .navigationTitle("Новая команда")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview {
    MainView(viewModel: MainViewModel(networkService: MockNetworkService()))
}

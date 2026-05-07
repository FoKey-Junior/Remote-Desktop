// MainView.swift
// Remote-Desktop
//
// Главный экран приложения (для авторизованных пользователей).
// Список команд, добавление и выполнение — в стиле Liquid Glass.

import SwiftUI

struct MainView: View {
    
    @StateObject var viewModel: MainViewModel
    @State private var appearAnimation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Анимированный фон
                AnimatedBackground()
                
                // Контент
                if viewModel.isLoading && viewModel.commands.isEmpty {
                    loadingView
                } else if viewModel.commands.isEmpty {
                    emptyStateView
                } else {
                    commandListView
                }
                
                // Оверлей выполнения команды
                if viewModel.isExecuting {
                    executingOverlay
                }
            }
            .navigationTitle("")
            .toolbar {
                // Заголовок слева
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 10) {
                        // Стеклянная иконка
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 34, height: 34)
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                                )
                            
                            Image(systemName: "terminal.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.5, green: 0.3, blue: 0.9),
                                            Color(red: 0.3, green: 0.6, blue: 0.9)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        Text("Команды")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                
                // Кнопки справа
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Добавить команду — стеклянная кнопка
                    Button {
                        viewModel.showAddSheet = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                                )
                                .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.4, green: 0.2, blue: 0.9),
                                            Color(red: 0.3, green: 0.5, blue: 0.9)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                    
                    // Выйти — стеклянная кнопка
                    Button {
                        withAnimation {
                            viewModel.logout()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.15), lineWidth: 0.5)
                                )
                                .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
                            
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white.opacity(0.55))
                        }
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .onAppear {
            viewModel.loadCommands()
            withAnimation(.easeOut(duration: 0.6)) {
                appearAnimation = true
            }
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddCommandSheet(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(.clear)
        }
        .alert("Результат", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        GlassCard(cornerRadius: 20) {
            VStack(spacing: 18) {
                ProgressView()
                    .scaleEffect(1.3)
                    .tint(.white)
                Text("Загрузка команд...")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(30)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        GlassCard(cornerRadius: 24) {
            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.15), lineWidth: 0.5)
                        )
                    
                    Image(systemName: "tray")
                        .font(.system(size: 28, weight: .thin))
                        .foregroundStyle(.white.opacity(0.4))
                }
                
                Text("Нет команд")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                
                Text("Нажмите «+» чтобы добавить\nпервую команду")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.35))
                    .multilineTextAlignment(.center)
            }
            .padding(30)
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - Command List
    
    private var commandListView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 10) {
                // Статистика
                statsBar
                    .padding(.top, 4)
                
                ForEach(Array(viewModel.commands.enumerated()), id: \.element.id) { index, command in
                    CommandRow(command: command) {
                        viewModel.executeCommand(command)
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 20)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.05),
                        value: appearAnimation
                    )
                }
                
                Color.clear.frame(height: 20)
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Stats Bar
    
    private var statsBar: some View {
        HStack {
            GlassBadge(
                text: "\(viewModel.commands.count) команд",
                color: Color(red: 0.4, green: 0.3, blue: 0.9)
            )
            
            Spacer()
            
            GlassBadge(
                text: "● Онлайн",
                color: Color(red: 0.2, green: 0.8, blue: 0.5)
            )
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 4)
    }
    
    // MARK: - Executing Overlay
    
    private var executingOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .transition(.opacity)
            
            GlassCard(cornerRadius: 24) {
                VStack(spacing: 22) {
                    // Стеклянный круг с анимацией
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(
                                        AngularGradient(
                                            colors: [
                                                Color(red: 0.4, green: 0.2, blue: 0.9),
                                                Color(red: 0.3, green: 0.6, blue: 0.9),
                                                Color(red: 0.4, green: 0.2, blue: 0.9)
                                            ],
                                            center: .center
                                        ),
                                        lineWidth: 2
                                    )
                                    .rotationEffect(.degrees(viewModel.isExecuting ? 360 : 0))
                                    .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: viewModel.isExecuting)
                            )
                        
                        Image(systemName: "play.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                    Text("Выполняется...")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(viewModel.executingCommandName)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.45))
                }
                .padding(32)
            }
            .transition(.scale(scale: 0.85).combined(with: .opacity))
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.isExecuting)
    }
}

// MARK: - Command Row

struct CommandRow: View {
    
    let command: Command
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    private var iconName: String {
        let name = command.name.lowercased()
        if name.contains("выключ") && !name.contains("звук") { return "power" }
        if name.contains("перезагру") { return "arrow.clockwise" }
        if name.contains("блокир") || name.contains("замок") { return "lock.fill" }
        if name.contains("браузер") || name.contains("browser") { return "globe" }
        if name.contains("скриншот") || name.contains("screenshot") { return "camera.viewfinder" }
        if name.contains("громкост") && name.contains("увелич") { return "speaker.wave.3.fill" }
        if name.contains("громкост") && name.contains("уменьш") { return "speaker.wave.1.fill" }
        if name.contains("звук") { return "speaker.slash.fill" }
        if name.contains("пауз") { return "pause.circle.fill" }
        if name.contains("плей") || name.contains("воспро") { return "play.circle.fill" }
        return "terminal.fill"
    }
    
    private var accentColor: Color {
        let name = command.name.lowercased()
        if name.contains("выключ") && !name.contains("звук") { return Color(red: 0.9, green: 0.3, blue: 0.3) }
        if name.contains("перезагру") { return Color(red: 0.9, green: 0.6, blue: 0.2) }
        if name.contains("блокир") { return Color(red: 0.9, green: 0.8, blue: 0.2) }
        if name.contains("браузер") { return Color(red: 0.3, green: 0.7, blue: 0.9) }
        if name.contains("скриншот") { return Color(red: 0.4, green: 0.8, blue: 0.5) }
        if name.contains("громкост") || name.contains("звук") { return Color(red: 0.6, green: 0.4, blue: 0.9) }
        return Color(red: 0.4, green: 0.5, blue: 0.9)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Стеклянная иконка
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 46, height: 46)
                        .overlay(
                            Circle()
                                .fill(accentColor.opacity(0.12))
                        )
                        .overlay(
                            Circle()
                                .stroke(accentColor.opacity(0.25), lineWidth: 0.6)
                        )
                        .shadow(color: accentColor.opacity(0.15), radius: 6, x: 0, y: 2)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(accentColor)
                }
                
                // Название команды
                VStack(alignment: .leading, spacing: 3) {
                    Text(command.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Text("Нажмите для выполнения")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.3))
                }
                
                Spacer()
                
                // Стеклянная кнопка play
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.15), lineWidth: 0.5)
                        )
                    
                    Image(systemName: "play.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.ultraThinMaterial)
                    
                    // Верхний блик
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(isPressed ? 0.1 : 0.06),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // Граница
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(isPressed ? 0.3 : 0.18),
                                    .white.opacity(0.03)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.6
                        )
                }
            )
            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
            .shadow(color: accentColor.opacity(isPressed ? 0.1 : 0), radius: 10, x: 0, y: 3)
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Add Command Sheet

struct AddCommandSheet: View {
    
    @ObservedObject var viewModel: MainViewModel
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            // Фон шита — тоже анимированный
            AnimatedBackground()
            
            VStack(spacing: 24) {
                // Заголовок в стеклянной карточке
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.2), lineWidth: 0.6)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
                        
                        Image(systemName: "plus.rectangle.on.rectangle")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.4, green: 0.2, blue: 0.9),
                                        Color(red: 0.3, green: 0.6, blue: 0.9)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    Text("Новая команда")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("Введите название команды для ПК")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.top, 12)
                
                GlassDivider()
                    .padding(.horizontal, 8)
                
                // Поле ввода
                GlassTextField(
                    placeholder: "Название команды",
                    text: $viewModel.newCommandName,
                    icon: "terminal.fill"
                )
                .padding(.horizontal, 4)
                
                // Кнопка добавления
                GlassButton(
                    title: "Добавить команду",
                    icon: "plus.circle.fill",
                    gradient: [
                        Color(red: 0.2, green: 0.7, blue: 0.5),
                        Color(red: 0.2, green: 0.5, blue: 0.7)
                    ],
                    isLoading: viewModel.isAddingCommand
                ) {
                    viewModel.addCommand()
                }
                .padding(.horizontal, 4)
                
                Spacer()
            }
            .padding(24)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 15)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                appearAnimation = true
            }
        }
    }
}

// MARK: - Previews

#Preview {
    MainView(viewModel: MainViewModel(networkService: MockNetworkService()))
        .preferredColorScheme(.dark)
}

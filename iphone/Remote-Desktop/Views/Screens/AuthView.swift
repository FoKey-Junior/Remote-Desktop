// AuthView.swift
// Remote-Desktop
//
// Экран авторизации / регистрации.
// Liquid Glass дизайн с многослойными стеклянными элементами.

import SwiftUI

struct AuthView: View {
    
    @StateObject var viewModel: AuthViewModel
    @State private var isRegistering = false
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            // Анимированный фон
            AnimatedBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer(minLength: 50)
                    
                    // Логотип и заголовок
                    headerSection
                    
                    Spacer(minLength: 36)
                    
                    // Форма авторизации
                    authForm
                    
                    Spacer(minLength: 20)
                    
                    // Разделитель
                    orDivider
                    
                    Spacer(minLength: 20)
                    
                    // Переключатель Вход / Регистрация
                    toggleSection
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 24)
            }
        }
        .alert("Ошибка", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Неизвестная ошибка")
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) {
                appearAnimation = true
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 18) {
            // Иконка в стеклянном круге
            ZStack {
                // Внешнее свечение
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.4, green: 0.2, blue: 0.9).opacity(0.25),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 70
                        )
                    )
                    .frame(width: 130, height: 130)
                
                // Стеклянный круг
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 88, height: 88)
                    .overlay(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.12), .clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.35),
                                        .white.opacity(0.05),
                                        .white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.8
                            )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
                
                Image(systemName: "desktopcomputer.and.arrow.down")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.65)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            
            VStack(spacing: 6) {
                Text("Remote Desktop")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("Пульт управления вашим ПК")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : -25)
    }
    
    // MARK: - Auth Form
    
    private var authForm: some View {
        GlassCard(cornerRadius: 26) {
            VStack(spacing: 22) {
                // Заголовок формы с бейджем
                HStack {
                    Text(isRegistering ? "Регистрация" : "Вход")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    GlassBadge(
                        text: isRegistering ? "NEW" : "AUTH",
                        color: isRegistering
                            ? Color(red: 0.2, green: 0.7, blue: 0.5)
                            : Color(red: 0.4, green: 0.3, blue: 0.9)
                    )
                }
                
                GlassDivider()
                
                // Поле Email
                GlassTextField(
                    placeholder: "Email или логин",
                    text: $viewModel.email,
                    icon: "envelope.fill"
                )
                
                // Поле Пароль
                GlassTextField(
                    placeholder: "Пароль",
                    text: $viewModel.password,
                    icon: "lock.fill",
                    isSecure: true
                )
                
                // Кнопки действий
                VStack(spacing: 12) {
                    if isRegistering {
                        GlassButton(
                            title: "Зарегистрироваться",
                            icon: "person.badge.plus",
                            gradient: [
                                Color(red: 0.2, green: 0.6, blue: 0.9),
                                Color(red: 0.3, green: 0.4, blue: 0.9)
                            ],
                            isLoading: viewModel.isLoading
                        ) {
                            viewModel.register()
                        }
                    } else {
                        GlassButton(
                            title: "Войти",
                            icon: "arrow.right.circle.fill",
                            isLoading: viewModel.isLoading
                        ) {
                            viewModel.login()
                        }
                    }
                }
            }
            .padding(24)
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 30)
    }
    
    // MARK: - Or Divider
    
    private var orDivider: some View {
        HStack(spacing: 16) {
            GlassDivider()
            Text("или")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.3))
            GlassDivider()
        }
        .padding(.horizontal, 20)
        .opacity(appearAnimation ? 1 : 0)
    }
    
    // MARK: - Toggle
    
    private var toggleSection: some View {
        GlassSecondaryButton(
            title: isRegistering ? "Уже есть аккаунт? Войти" : "Нет аккаунта? Создать",
            icon: isRegistering ? "person.fill" : "person.badge.plus"
        ) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isRegistering.toggle()
            }
        }
        .opacity(appearAnimation ? 1 : 0)
    }
}

#Preview {
    AuthView(viewModel: AuthViewModel(networkService: MockNetworkService()))
}

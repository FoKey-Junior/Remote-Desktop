// AuthView.swift
// Remote-Desktop
//
// Экран авторизации / регистрации.
// Чистый Apple-дизайн в стиле Apple ID Sign In.

import SwiftUI

struct AuthView: View {
    
    @StateObject var viewModel: AuthViewModel
    @State private var isRegistering = false
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer(minLength: 60)
                    
                    headerSection
                    
                    Spacer(minLength: AppStyle.spacingXL)
                    
                    formSection
                    
                    Spacer(minLength: AppStyle.spacingL)
                    
                    toggleSection
                    
                    Spacer(minLength: AppStyle.spacingXXL)
                }
                .padding(.horizontal, AppStyle.spacingL)
            }
        }
        .alert("Ошибка", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Неизвестная ошибка")
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appearAnimation = true
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 14) {
            Image(systemName: "desktopcomputer")
                .font(.system(size: 56, weight: .thin))
                .foregroundStyle(AppStyle.accent)
                .padding(.bottom, 4)
            
            Text("Remote Desktop")
                .font(.largeTitle.bold())
                .foregroundStyle(Color(.label))
            
            Text("Управление вашим ПК")
                .font(.subheadline)
                .foregroundStyle(Color(.secondaryLabel))
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : -10)
    }
    
    // MARK: - Form
    
    private var formSection: some View {
        VStack(spacing: AppStyle.spacingM) {
            // Поля ввода в карточке
            AppleCard {
                VStack(spacing: 0) {
                    // Email
                    HStack(spacing: 12) {
                        Image(systemName: "envelope")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color(.tertiaryLabel))
                            .frame(width: 22)
                        
                        TextField("Email или логин", text: $viewModel.email)
                            .textContentType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    
                    Divider()
                        .padding(.leading, 50)
                    
                    // Пароль
                    HStack(spacing: 12) {
                        Image(systemName: "lock")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color(.tertiaryLabel))
                            .frame(width: 22)
                        
                        SecureField("Пароль", text: $viewModel.password)
                            .textContentType(.password)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                }
            }
            
            // Кнопка действия
            ApplePrimaryButton(
                title: isRegistering ? "Зарегистрироваться" : "Войти",
                isLoading: viewModel.isLoading
            ) {
                if isRegistering {
                    viewModel.register()
                } else {
                    viewModel.login()
                }
            }
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 15)
    }
    
    // MARK: - Toggle
    
    private var toggleSection: some View {
        AppleSecondaryButton(
            title: isRegistering ? "Уже есть аккаунт? Войти" : "Нет аккаунта? Создать"
        ) {
            withAnimation(.easeInOut(duration: 0.25)) {
                isRegistering.toggle()
            }
        }
        .opacity(appearAnimation ? 1 : 0)
    }
}

#Preview {
    AuthView(viewModel: AuthViewModel(networkService: MockNetworkService()))
}

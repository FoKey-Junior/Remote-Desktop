#include <QRegularExpression>
#include <QMessageBox>
#include <QDebug>
#include "start_window.h"
#include "ui_start_window.h"

StartWindow::StartWindow(QWidget *parent) : QMainWindow(parent), ui(new Ui::StartWindow) {
    ui->setupUi(this);

    setFixedSize(320, 241);
    setWindowFlags(windowFlags() & ~Qt::WindowMaximizeButtonHint);

    connect(ui->button_login, &QPushButton::clicked, this, &StartWindow::onLoginClicked);
    connect(ui->button_register, &QPushButton::clicked, this, &StartWindow::onRegisterClicked);
}

StartWindow::~StartWindow() {
    delete ui;
}

void StartWindow::onLoginClicked() {
    const QString email = ui->login_input_email->text();
    const QString password = ui->login_input_password->text();
    static const QRegularExpression regex(R"((\w+)(\.|_)?(\w*)@(\w+)(\.(\w+))+)");

    if (email.isEmpty() || password.isEmpty()) {
        QMessageBox::warning(this, "Ошибка", "Заполните все поля");
        return;
    }

    if (!regex.match(email).hasMatch()) {
        QMessageBox::warning(this, "Ошибка", "Некорректный email");
        return;
    }

    qDebug() << "Login clicked email: " << email << " password: " << password;
}

void StartWindow::onRegisterClicked() {
    const QString email = ui->register_input_email->text();
    const QString password_1 = ui->register_input_password->text();
    const QString password_2 = ui->register_input_password_2->text();

    if (email.isEmpty() || password_1.isEmpty() || password_2.isEmpty()) {
        QMessageBox::warning(this, "Ошибка", "Заполните все поля");
        return;
    }

    static const QRegularExpression regex(R"((\w+)(\.|_)?(\w*)@(\w+)(\.(\w+))+)");
    if (!regex.match(email).hasMatch()) {
        QMessageBox::warning(this, "Ошибка", "Некорректный email");
        return;
    }

    if (password_1 == password_2) {
        QMessageBox::warning(this, "Ошибка", "Пароли не совпадают");
        return;
    }

    qDebug() << "Register clicked email: " << email << " password_1: " << password_1 << " password_2: " << password_2;
}
#include <QRegularExpression>
#include "start_window.h"
#include "string_handler.h"
#include "ui_start_window.h"

StartWindow::StartWindow(QWidget *parent) : QMainWindow(parent), ui(new Ui::StartWindow) {
    ui->setupUi(this);
    qApp->setStyleSheet("QLabel { color: red; }");

    setFixedSize(320, 241);
    setWindowFlags(windowFlags() & ~Qt::WindowMaximizeButtonHint);

    connect(ui->login_button, &QPushButton::clicked, this, &StartWindow::onLoginClicked);
    connect(ui->register_button, &QPushButton::clicked, this, &StartWindow::onRegisterClicked);
}

StartWindow::~StartWindow() {
    delete ui;
}

void StartWindow::onLoginClicked() {
    const QString email = ui->login_input_email->text();
    const QString password = ui->login_input_password->text();
    static const QRegularExpression regex(R"((\w+)(\.|_)?(\w*)@(\w+)(\.(\w+))+)");

    ui->login_error_email->clear();
    ui->login_error_password->clear();
    ui->login_error->clear();

    if (email.isEmpty() || password.isEmpty()) {
        ui->login_error->setText("Заполните все поля");
        return;
    }

    if (!StringHandler::validateEmail(email, ui->login_error_email)) return;
    if (!StringHandler::validatePassword(password, ui->login_error_password)) return;
}

void StartWindow::onRegisterClicked() {
    const QString email = ui->register_input_email->text();
    const QString password_1 = ui->register_input_password->text();
    const QString password_2 = ui->register_input_password_2->text();

    ui->register_error_email->clear();
    ui->register_error_password->clear();
    ui->register_error->clear();

    if (email.isEmpty() || password_1.isEmpty() || password_2.isEmpty()) {
        ui->register_error->setText("Заполните все поля");
        return;
    }


    if (email.isEmpty() || password_1.isEmpty() || password_2.isEmpty()) {
        ui->register_error->setText("Заполните все поля");
        return;
    }

    if (!StringHandler::validateEmail(email, ui->register_error_email)) return;

    if (password_1 != password_2) {
        ui->register_error_password->setText("Пароли не совпадают"); return;
    }

    if (!StringHandler::validatePassword(password_1, ui->register_error_password)) return;
}
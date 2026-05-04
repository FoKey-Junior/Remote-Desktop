#include <qdatetime.h>

#include "ui_start_window.h"
#include "ui_main_window.h"
#include "windows/start_window.h"
#include "windows/main_window.h"

#include "services/string_handler.h"
#include "services/requests.h"

Requests requests;

StartWindow::StartWindow(QWidget* parent)
    : QMainWindow(parent)
      , ui(new Ui::StartWindow) {
    ui->setupUi(this);
}

StartWindow::~StartWindow() {
    delete ui;
}

void StartWindow::loading_animation(QTimer& timer, QLabel* label, const QString& base_text) {
    label->setText(base_text);

    connect(&timer, &QTimer::timeout, this, [label, base_text]() {
        QString current_text = label->text();

        if (current_text.endsWith("...")) {
            label->setText(base_text);
        } else {
            label->setText(current_text + ".");
        }
    });

    timer.start(500);
}

void StartWindow::on_login_button_clicked() {
    const QString email = ui->login_input_email->text();
    const QString password = ui->login_input_password->text();

    ui->login_error_email->clear();
    ui->login_error_password->clear();
    ui->login_error->clear();

    if (email.isEmpty() || password.isEmpty()) {
        ui->login_error->setText("Заполните все поля");
        return;
    }

    if (!StringHandler::validate_email(email, ui->login_error_email)) return;
    if (!StringHandler::validate_password(password, ui->login_error_password)) return;

    QTimer animation_timer;
    loading_animation(animation_timer, ui->login_error, "Запрос отправляется");
    const auto result = requests.submit_authorization("http://localhost:4000/api/authorization", email, password);
    animation_timer.stop();

    if (!result.has_value()) {
        auto* main_window = new MainWindow();

        main_window->setAttribute(Qt::WA_DeleteOnClose);
        main_window->show();
        this->close();
    } else {
        ui->login_error->setText(result.value());
    }
}

void StartWindow::on_register_button_clicked() {
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

    if (!StringHandler::validate_email(email, ui->register_error_email)) return;
    if (!StringHandler::validate_password(password_1, ui->register_error_password)) return;
    if (!StringHandler::validate_password(password_2, ui->register_error_password)) return;

    if (password_1 != password_2) {
        ui->register_error->setText("Пароль должен совпадать");
        return;
    }

    QTimer animation_timer;
    loading_animation(animation_timer, ui->register_error, "Запрос отправляется");
    const auto result = requests.submit_authorization("http://localhost:4000/api/registration", email, password_1);
    animation_timer.stop();

    if (!result.has_value()) {
        auto* main_window = new MainWindow();

        main_window->setAttribute(Qt::WA_DeleteOnClose);
        main_window->show();
        this->close();
    } else {
        ui->register_error->setText(result.value());
    }
}

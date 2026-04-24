#include "ui_start_window.h"
#include "windows/start_window.h"
#include "services/string_handler.h"
#include "services/requests.h"

StartWindow::StartWindow(QWidget* parent)
    : QMainWindow(parent)
    , ui(new Ui::StartWindow)
{
    ui->setupUi(this);

    connect(ui->login_button, &QPushButton::clicked,
            this, &StartWindow::on_login_button_clicked);

    connect(ui->register_button, &QPushButton::clicked,
            this, &StartWindow::on_register_button_clicked);
}

StartWindow::~StartWindow()
{
    delete ui;
}

void StartWindow::on_login_button_clicked() const
{
    const QString email = ui->login_input_email->text();
    const QString password = ui->login_input_password->text();

    ui->login_error_email->clear();
    ui->login_error_password->clear();
    ui->login_error->clear();

    if (email.isEmpty() || password.isEmpty())
    {
        ui->login_error->setText("Заполните все поля");
        return;
    }

    if (!StringHandler::validate_email(email, ui->login_error_email)) return;
    if (!StringHandler::validate_password(password, ui->login_error_password)) return;

    Requests::send_request("http://localhost:4000/api/authorization", email, password);
}

void StartWindow::on_register_button_clicked() const
{
    const QString email = ui->register_input_email->text();
    const QString password_1 = ui->register_input_password->text();
    const QString password_2 = ui->register_input_password_2->text();

    ui->register_error_email->clear();
    ui->register_error_password->clear();
    ui->register_error->clear();

    if (email.isEmpty() || password_1.isEmpty() || password_2.isEmpty())
    {
        ui->register_error->setText("Заполните все поля");
        return;
    }

    if (!StringHandler::validate_email(email, ui->register_error_email)) return;
    if (!StringHandler::validate_password(password_1, ui->register_error_password)) return;
    if (!StringHandler::validate_password(password_2, ui->register_error_password)) return;

    if (password_1 != password_2)
    {
        ui->register_error->setText("Пароль должен совпадать");
        return;
    }

    Requests::send_request("http://localhost:4000/api/registration", email, password_1);
}
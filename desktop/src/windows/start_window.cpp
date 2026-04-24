#include "start_window.h"
#include "ui_start_window.h"
#include "string_handler.h"

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

void StartWindow::on_login_button_clicked()
{
    const QString email = ui->login_input_email->text();
    const QString password = ui->login_input_password->text();

    ui->login_error_email->clear();
    ui->login_error_password->clear();
    ui->login_error->clear();

    if (!StringHandler::validateEmail(email, ui->login_error_email)) return;
    if (!StringHandler::validatePassword(password, ui->login_error_password)) return;

    StringHandler::authorization(email, password);
}

void StartWindow::on_register_button_clicked()
{
    const QString email = ui->register_input_email->text();
    const QString password_1 = ui->register_input_password->text();
    const QString password_2 = ui->register_input_password_2->text();

    ui->register_error_email->clear();
    ui->register_error_password->clear();
    ui->register_error->clear();

    if (!StringHandler::validateEmail(email, ui->register_error_email)) return;
    if (!StringHandler::validatePassword(password_1, ui->register_error_password)) return;
    if (!StringHandler::validatePassword(password_2, ui->register_error_password)) return;

    if (password_1 != password_2)
    {
        ui->register_error->setText("Пароль должен совпадать");
        return;
    }

    StringHandler::registration(email, password_1);
}
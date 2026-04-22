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
    QString email = ui->login_input_email->text();
    QString password = ui->login_input_password->text();

    if (!StringHandler::validateEmail(email, ui->login_error_email)) return;
    if (!StringHandler::validatePassword(password, ui->login_error_password)) return;

    StringHandler::authorization(email, password);
}

void StartWindow::on_register_button_clicked()
{
    QString email = ui->register_input_email->text();
    QString password = ui->register_input_password->text();

    if (!StringHandler::validateEmail(email, ui->register_error_email)) return;
    if (!StringHandler::validatePassword(password, ui->register_error_password)) return;

    StringHandler::registration(email, password);
}
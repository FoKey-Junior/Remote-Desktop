#include "start_window.h"
#include "ui_start_window.h"
#include <QDebug>

StartWindow::StartWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::StartWindow)
{
    ui->setupUi(this);
    setFixedSize(320, 241);
    setWindowFlags(windowFlags() & ~Qt::WindowMaximizeButtonHint);

    connect(ui->button_login, &QPushButton::clicked,
            this, &StartWindow::onLoginClicked);

    connect(ui->button_register, &QPushButton::clicked,
            this, &StartWindow::onRegisterClicked);
}

StartWindow::~StartWindow()
{
    delete ui;
}

void StartWindow::onLoginClicked()
{
    qDebug() << "Login clicked";
}

void StartWindow::onRegisterClicked()
{
    qDebug() << "Register clicked";
}
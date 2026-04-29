#include "services/jwt.h"
#include "windows/main_window.h"
#include "ui_main_window.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow) {

    token = Jwt::get_token();

    if (token.empty()) {
        return;
    }

    ui->setupUi(this);
}

MainWindow::~MainWindow() {
    delete ui;
}


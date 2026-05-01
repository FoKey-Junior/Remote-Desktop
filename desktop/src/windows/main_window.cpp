#include "services/jwt.h"
#include "windows/main_window.h"
#include "ui_main_window.h"

#include <qdebug.h>

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

void MainWindow::on_switch_automatic_start_toggled(bool checked) {
    qDebug() << checked;
}

void MainWindow::on_switch_stealth_launch_toggled(bool checked) {
     qDebug() << checked;
}
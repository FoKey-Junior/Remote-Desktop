#include <filesystem>

#include "ui_main_window.h"
#include "ui_start_window.h"
#include "windows/main_window.h"
#include "windows/start_window.h"

#include "services/jwt.h"
#include "services/requests.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow) {

    token = Jwt::get_token();

    if (token.empty()) {
        return;
    }

    ui->setupUi(this);

    Requests requests;
    if (requests.server_status() == true) {
        ui->display_connection_status->setText("Статус сети: подключено к серверу");
    } else {
        ui->display_connection_status->setText("Статус сети: не подключено к серверу");
    }
}

MainWindow::~MainWindow() {
    delete ui;
}

void MainWindow::on_automatic_start_toggled(bool checked) {
    is_automatic_start_enabled = checked;
}

void MainWindow::on_stealth_launch_toggled(bool checked) {
    is_hidden_start = checked;
}

void MainWindow::on_button_logout_clicked() {
    if (std::filesystem::exists("data.bin")) {
        std::filesystem::remove("data.bin");

        auto* start_window = new StartWindow();

        start_window->setAttribute(Qt::WA_DeleteOnClose);
        start_window->show();
        this->close();
    }
}
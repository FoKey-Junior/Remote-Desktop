#include <sstream>

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QPainter>
#include <QPixmap>
#include <QProcess>
#include <QStandardPaths>
#include <QString>
#include <QTextStream>

#include "ui_main_window.h"
#include "ui_start_window.h"
#include "windows/main_window.h"
#include "windows/start_window.h"

#include "services/storage.h"

void MainWindow::display_commands(QTimer* timer, QLabel* label) {
    connect(timer, &QTimer::timeout, this, [label, this]() {
        if (const auto result = requests.get_command(token); result.has_value()) {
            const QString command = QString::fromStdString(result.value());
            label->setText("Список команд: " + command);

            QProcess::startDetached("bash", QStringList() << "-c" << command);
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

    if (requests.server_status()) {
        ui->display_connection_status->setText("Статус сети: подключено к серверу");
    } else {
        ui->display_connection_status->setText("Статус сети: не подключено к серверу");
    }

    display_timer = new QTimer(this);
    display_commands(display_timer, ui->display_commands);

    setup_tray_icon();

    if (is_hidden_start) {
        tray_icon->show();
    }
}

MainWindow::~MainWindow() {
    delete ui;
}


void MainWindow::on_automatic_start_toggled(const bool checked) {
    is_automatic_start = checked;
    const std::string value = is_automatic_start ? "true" : "false";
    storage.save(value, 1);

    const QString autostart_dir = QDir::homePath() + "/.config/autostart";
    const QString desktop_file = autostart_dir + "/remote_desktop_client.desktop";

    if (checked) {
        QDir().mkpath(autostart_dir);

        QFile file(desktop_file);
        if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            QTextStream out(&file);
            out << "[Desktop Entry]\n";
            out << "Type=Application\n";
            out << "Name=Remote Desktop Client\n";
            out << "Exec=" << QCoreApplication::applicationFilePath() << "\n";
            out << "X-GNOME-Autostart-enabled=true\n";
            file.close();
        }
    } else {
        QFile::remove(desktop_file);
    }
}

void MainWindow::setup_tray_icon() {
    QPixmap pixmap(64, 64);
    pixmap.fill(Qt::transparent);
    QPainter painter(&pixmap);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.setBrush(QColor(0, 120, 215));
    painter.setPen(Qt::NoPen);
    painter.drawEllipse(4, 4, 56, 56);
    painter.end();

    tray_icon = new QSystemTrayIcon(QIcon(pixmap), this);
    tray_icon->setToolTip("Remote Desktop Client");

    tray_menu = new QMenu(this);

    auto* show_action = new QAction("Показать", this);
    connect(show_action, &QAction::triggered, this, [this]() {
        showNormal();
        activateWindow();
    });

    auto* quit_action = new QAction("Выход", this);
    connect(quit_action, &QAction::triggered, this, []() {
        QCoreApplication::quit();
    });

    tray_menu->addAction(show_action);
    tray_menu->addAction(quit_action);
    tray_icon->setContextMenu(tray_menu);

    connect(tray_icon, &QSystemTrayIcon::activated, this,
        [this](QSystemTrayIcon::ActivationReason reason) {
            if (reason == QSystemTrayIcon::Trigger) {
                if (isVisible()) {
                    hide();
                } else {
                    showNormal();
                    activateWindow();
                }
            }
        });
}

void MainWindow::closeEvent(QCloseEvent* event) {
    if (tray_icon && tray_icon->isVisible()) {
        hide();
        event->ignore();
    } else {
        event->accept();
    }
}

void MainWindow::on_hidden_start_toggled(const bool checked) {
    is_hidden_start = checked;
    const std::string value = is_hidden_start ? "true" : "false";
    storage.save(value, 2);

    if (!tray_icon) return;

    if (checked) {
        tray_icon->show();
    } else {
        tray_icon->hide();
    }
}

void MainWindow::on_button_logout_clicked() {
    const QString config_dir = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
    const QString data_file = config_dir + "/data.bin";

    if (QFile::exists(data_file)) {
        QFile::remove(data_file);

        auto* start_window = new StartWindow();

        start_window->setAttribute(Qt::WA_DeleteOnClose);
        start_window->show();
        this->close();
    }
}
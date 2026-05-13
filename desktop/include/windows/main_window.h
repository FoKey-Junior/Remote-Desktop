#pragma once

#include <QCloseEvent>
#include <QLabel>
#include <QMainWindow>
#include <QMenu>
#include <QSystemTrayIcon>

#include "services/requests.h"
#include "services/storage.h"

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow() override;

    [[nodiscard]] bool hidden_start() const { return is_hidden_start; }

protected:
    void closeEvent(QCloseEvent* event) override;

private slots:
    void on_automatic_start_toggled(bool checked);
    void on_hidden_start_toggled(bool checked);
    void on_button_logout_clicked();

private:
    std::string token;
    bool is_automatic_start = false;
    bool is_hidden_start = false;

    Ui::MainWindow *ui;
    QTimer* display_timer{nullptr};
    QSystemTrayIcon* tray_icon{nullptr};
    QMenu* tray_menu{nullptr};
    Requests requests;
    Storage storage;

    void display_commands(QTimer* timer, QLabel* label);
    void setup_tray_icon();
};
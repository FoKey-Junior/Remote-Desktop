#pragma once

#include <QMainWindow>
#include <QLabel>

#include "services/requests.h"

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow() override;

private slots:
    void on_automatic_start_toggled(const bool checked);
    void on_stealth_launch_toggled(const bool checked);
    void on_button_logout_clicked();

private:
    std::optional<std::string> token;
    bool is_automatic_start_enabled;
    bool is_hidden_start;

    Ui::MainWindow *ui;
    Requests requests;
    QTimer* command_timer;

    void display_commands(QTimer* timer, QLabel* label);
};
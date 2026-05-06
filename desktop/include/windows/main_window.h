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
    void on_automatic_start_toggled(bool checked);
    void on_hidden_start_toggled(bool checked);
    void on_button_logout_clicked();

private:
    std::optional<std::string> token;
    bool is_automatic_start = false;
    bool is_hidden_start = false;

    Ui::MainWindow *ui;
    Requests requests;
    QTimer* display_timer{nullptr};

    void display_commands(QTimer* timer, QLabel* label);
};
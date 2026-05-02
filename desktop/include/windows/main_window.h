#pragma once

#include <QMainWindow>

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void on_automatic_start_toggled(bool checked);
    void on_stealth_launch_toggled(bool checked);
    void on_button_logout_clicked();

private:
    std::string token;
    bool is_automatic_start_enabled;
    bool is_hidden_start;

    Ui::MainWindow *ui;
};
#pragma once

#include <QMainWindow>
#include <QLabel>
#include <QTimer>

QT_BEGIN_NAMESPACE
namespace Ui { class StartWindow; }
QT_END_NAMESPACE

class StartWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit StartWindow(QWidget* parent = nullptr);
    ~StartWindow() override;

private slots:
    void on_login_button_clicked();
    void on_register_button_clicked();

private:
    Ui::StartWindow* ui;
    QTimer* loading_animation(QLabel* label, const QString& base_text);
};
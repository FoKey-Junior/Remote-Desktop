#pragma once

#include <QMainWindow>

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
    void on_login_button_clicked() const;
    void on_register_button_clicked() const;

private:
    Ui::StartWindow* ui;
};
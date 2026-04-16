#ifndef STARTWINDOW_H
#define STARTWINDOW_H

#include <QMainWindow>

QT_BEGIN_NAMESPACE
namespace Ui {
class startwindow;
}
QT_END_NAMESPACE

class startwindow : public QMainWindow
{
    Q_OBJECT

public:
    startwindow(QWidget *parent = nullptr);
    ~startwindow();

private:
    Ui::startwindow *ui;
};
#endif // STARTWINDOW_H

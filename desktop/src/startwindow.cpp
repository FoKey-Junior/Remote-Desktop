#include "startwindow.h"
#include "./ui_startwindow.h"

startwindow::startwindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::startwindow)
{
    ui->setupUi(this);
}

startwindow::~startwindow()
{
    delete ui;
}

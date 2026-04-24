#include <QApplication>
#include "windows/start_window.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    StartWindow w;
    w.show();
    return QApplication::exec();
}

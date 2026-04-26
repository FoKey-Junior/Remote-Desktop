#include "filesystem"
#include <QApplication>
#include "windows/main_window.h"
#include "windows/start_window.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    if (std::filesystem::exists("data.bin"))
    {
        MainWindow window;
        window.show();
        return QApplication::exec();
    }

    StartWindow window;
    window.show();
    return QApplication::exec();
}

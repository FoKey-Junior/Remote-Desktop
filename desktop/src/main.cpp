#include <QApplication>

#include "windows/main_window.h"
#include "windows/start_window.h"

#include "services/storage.h"

int main(int argc, char *argv[]) {
    QApplication a(argc, argv);
    Storage storage;

    if (storage.load(0) != "") {
        auto* window = new MainWindow();
        window->setAttribute(Qt::WA_DeleteOnClose);

        if (!window->hidden_start()) {
            window->show();
        }

        return QApplication::exec();
    }

    StartWindow window;
    window.show();
    return QApplication::exec();
}

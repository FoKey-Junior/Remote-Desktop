#include <QCoreApplication>
#include <QRegularExpression>
#include <QDebug>

int main(int argc, char *argv[]) {
    QCoreApplication a(argc, argv);
    QRegularExpression regex(R"((\w+)(\.|_)?(\w*)@(\w+)(\.(\w+))+)");
    qDebug() << regex.match("!!!invalid@email.com!!!").hasMatch();
    return 0;
}

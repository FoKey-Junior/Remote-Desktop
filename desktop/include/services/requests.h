#pragma once

#include <QObject>
#include <QString>
#include <QNetworkAccessManager>

class Requests : public QObject{
    Q_OBJECT
public:
    explicit Requests(QObject *parent = nullptr);
    bool server_status();
    QString submit_authorization(const QString& url_str, const QString& email, const QString& password);

private:
    QNetworkAccessManager *manager;
};
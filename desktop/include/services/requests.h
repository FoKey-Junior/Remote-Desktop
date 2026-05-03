#pragma once

#include <QObject>
#include <QString>
#include <QNetworkAccessManager>
#include <string>
#include <optional>

class Requests : public QObject{
    Q_OBJECT
public:
    explicit Requests(QObject *parent = nullptr);
    bool server_status();
    std::optional<QString> submit_authorization(const QString& url_str, const QString& email, const QString& password);
    std::optional<std::string> get_command(const std::string& token);

private:
    QNetworkAccessManager *manager;
};
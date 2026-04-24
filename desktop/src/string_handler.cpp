#include "string_handler.h"

#include <QRegularExpression>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QJsonObject>
#include <QJsonDocument>
#include <QDebug>

static void set_error(QLabel* label, const QString& message)
{
    if (label)
        label->setText(message);
}

bool StringHandler::validateEmail(const QString& email, QLabel* error_label)
{
    static const QRegularExpression regex(R"((\w+)(\.|_)?(\w*)@(\w+)(\.(\w+))+)");

    if (email.size() < 8)
    {
        set_error(error_label, "Минимум 8 символов");
        return false;
    }

    if (email.size() > 64)
    {
        set_error(error_label, "Максимум 64 символа");
        return false;
    }

    if (!regex.match(email).hasMatch())
    {
        set_error(error_label, "Некорректный email");
        return false;
    }

    return true;
}

bool StringHandler::validatePassword(const QString& password, QLabel* error_label)
{
    if (password.size() < 8)
    {
        set_error(error_label, "Минимум 8 символов");
        return false;
    }

    if (password.size() > 64)
    {
        set_error(error_label, "Максимум 64 символа");
        return false;
    }

    return true;
}

static void send_request(const QString& url_str, const QString& email, const QString& password)
{
    auto* manager = new QNetworkAccessManager();

    QUrl url(url_str);
    QNetworkRequest request(url);

    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject json;
    json["email"] = email;
    json["password"] = password;

    QByteArray data = QJsonDocument(json).toJson();

    QNetworkReply* reply = manager->post(request, data);

    QObject::connect(reply, &QNetworkReply::finished, [manager, reply]()
    {
        const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        const QByteArray response = reply->readAll();

        switch (status) {
            case 200: qDebug() << response; break;
        }

        reply->deleteLater();
        manager->deleteLater();
    });
}

void StringHandler::authorization(const QString& email, const QString& password)
{
    send_request("http://localhost:4000/api/authorization", email, password);
}

void StringHandler::registration(const QString& email, const QString& password)
{
    send_request("http://localhost:4000/api/registration", email, password);
}

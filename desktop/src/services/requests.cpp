#include <QEventLoop>
#include <QJsonObject>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QUrl>

#include "services/requests.h"
#include "services/jwt.h"

Requests::Requests(QObject* parent) : QObject(parent) {
    manager = new QNetworkAccessManager(this);
}

bool Requests::server_status() {
    const QNetworkRequest request(QUrl("http://localhost:4000/api"));
    QNetworkReply *reply = manager->get(request);

    QEventLoop loop;
    connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    reply->deleteLater();

    if (status == 200) {
        return true;
    }

    return false;
}

QString Requests::submit_authorization(const QString& url_str, const QString& email, const QString& password) {
    const QUrl url(url_str);
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject json;
    json["email"] = email;
    json["password"] = password;

    const QByteArray data = QJsonDocument(json).toJson();
    QNetworkReply* reply = manager->post(request, data);

    QEventLoop loop;
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    const QString response = reply->readAll();

    reply->deleteLater();
    manager->deleteLater();

    if (status == 200) {
        const std::string token = response.toStdString();
        Jwt::save_token(token);
        return QString("");
    }

    return response;
}
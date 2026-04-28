#include <QNetworkReply>
#include <QEventLoop>
#include <QUrl>
#include <QJsonObject>
#include <QJsonDocument>
#include "services/requests.h"
#include "services/jwt.h"

QString Requests::send_request(const QString& url_str, const QString& email, const QString& password) {
    auto* manager = new QNetworkAccessManager();

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
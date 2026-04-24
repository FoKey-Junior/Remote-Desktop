#include <QRegularExpression>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QJsonObject>
#include <QJsonDocument>
#include <QDebug>
#include "services/requests.h"

void Requests::send_request(const QString& url_str, const QString& email, const QString& password)
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

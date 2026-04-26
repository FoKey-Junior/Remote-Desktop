#pragma once

#include <QRegularExpression>

class Requests {
public:
    static void send_request(const QString& url_str, const QString& email, const QString& password);
};
#ifndef REMOTE_DESKTOP_CLIENT_REQUESTS_H
#define REMOTE_DESKTOP_CLIENT_REQUESTS_H


#include <QRegularExpression>

class Requests
{
public:
    static void send_request(const QString& url_str, const QString& email, const QString& password);
};


#endif
#include <QJsonObject>
#include "services/string_handler.h"

void StringHandler::set_error(QLabel* label, const QString& message)
{
    if (label)
        label->setText(message);
}

bool StringHandler::validate_email(const QString& email, QLabel* error_label)
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

bool StringHandler::validate_password(const QString& password, QLabel* error_label)
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

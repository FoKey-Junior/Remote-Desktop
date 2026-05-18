#include "services/string_handler.h"
#include <QRegularExpression>

std::optional<QString> StringHandler::validate_email(const QString& email) {
    static const QRegularExpression regex(R"(^(\w+)(\.|_)?(\w*)@(\w+)(\.(\w+))+$)");

    if (email.size() < 8) {
        return "Минимум 8 символов";
    }

    if (email.size() > 64) {
        return "Максимум 64 символа";
    }

    if (!regex.match(email).hasMatch()) {
        return "Некорректный email";
    }

    return std::nullopt;
}

std::optional<QString> StringHandler::validate_password(const QString& password) {
    if (password.size() < 8) {
        return "Минимум 8 символов";
    }

    if (password.size() > 64) {
        return "Максимум 64 символа";
    }

    return std::nullopt;
}

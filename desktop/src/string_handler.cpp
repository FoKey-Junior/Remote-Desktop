#include "string_handler.h"
#include <QRegularExpression>

void StringHandler::setError(QLabel* label, const QString& message)
{
    if (label)
        label->setText(message);
}

bool StringHandler::validateEmail(const QString& email, QLabel* errorLabel)
{
    static const QRegularExpression regex(
        R"((\w+)(\.|_)?(\w*)@(\w+)(\.(\w+))+)"
    );

    if (email.isEmpty()) {
        setError(errorLabel, "Email пустой");
        return false;
    }

    if (email.size() < 8) {
        setError(errorLabel, "Минимум 8 символов");
        return false;
    }

    if (email.size() > 64) {
        setError(errorLabel, "Максимум 64 символа");
        return false;
    }

    if (!regex.match(email).hasMatch()) {
        setError(errorLabel, "Некорректный email");
        return false;
    }

    return true;
}

bool StringHandler::validatePassword(const QString& password, QLabel* errorLabel)
{
    if (password.isEmpty()) {
        setError(errorLabel, "Пароль пустой");
        return false;
    }

    if (password.size() < 8) {
        setError(errorLabel, "Минимум 8 символов");
        return false;
    }

    if (password.size() > 64) {
        setError(errorLabel, "Максимум 64 символа");
        return false;
    }

    return true;
}
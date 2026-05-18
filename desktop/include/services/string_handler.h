#pragma once

#include <QString>
#include <optional>

class StringHandler {
public:
    static std::optional<QString> validate_email(const QString& email);
    static std::optional<QString> validate_password(const QString& password);
};
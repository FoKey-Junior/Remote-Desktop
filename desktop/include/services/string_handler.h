#pragma once

#include <QLabel>

class StringHandler
{
public:
    static bool validate_email(const QString& email, QLabel* error_label);
    static bool validate_password(const QString& password, QLabel* error_label);

private:
    static void set_error(QLabel* label, const QString& message);
};
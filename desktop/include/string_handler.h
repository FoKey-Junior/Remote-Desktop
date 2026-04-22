#pragma once

#include <QString>
#include <QLabel>

class StringHandler
{
public:
    static bool validateEmail(const QString& email, QLabel* errorLabel = nullptr);
    static bool validatePassword(const QString& password, QLabel* errorLabel = nullptr);

private:
    static void setError(QLabel* label, const QString& message);
};
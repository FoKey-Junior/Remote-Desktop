#pragma once

#include <QString>
#include <QLabel>

class StringHandler
{
public:
    static bool validateEmail(const QString& email, QLabel* error_label);
    static bool validatePassword(const QString& password, QLabel* error_label);

    static void authorization(const QString& email, const QString& password);
    static void registration(const QString& email, const QString& password);

private:
    static void setError(QLabel* label, const QString& message);
};
#include <jwt-cpp/jwt.h>
#include <sodium.h>
#include <iostream>
#include <string>
#include <vector>
#include <memory>

#include "api/Registration.hpp"
#include "services/Database.hpp"
#include "services/StringHandler.hpp"
#include "services/JWT.hpp"

Registration::Registration(const std::vector<std::string>& user_) {
    std::string email = user_[0];
    std::string password = user_[1];
    Database database;

    if (auto error = email_check(email)) {
        response = *error;
        return;
    }

    for (const std::string& input : user_) {
        if (auto error = length_check(input, 8, 64)) {
            response = *error;
            return;
        }
    }

    if (!database.uniqueness_check(email)) {
        response = "Пользователь с таким именем уже существует";
        return;
    }

    if (sodium_init() < 0) {
        response = "Ошибка инициализации криптобиблиотеки";
        return;
    }

    char hashed_password[crypto_pwhash_STRBYTES];
    if (crypto_pwhash_str(
            hashed_password,
            password.c_str(),
            password.size(),
            crypto_pwhash_OPSLIMIT_INTERACTIVE,
            crypto_pwhash_MEMLIMIT_INTERACTIVE) != 0) {
        response = "Ошибка хеширования пароля";
        return;
            }

    std::vector<std::string> data_hashed = user_;
    data_hashed[1] = hashed_password;

    if (!database.add_user(data_hashed)) {
        response = "Не удалось добавить пользователя в базу данных";
        return;
    }

    std::string token = JWT::create_token(email);
    response = std::string("Новый пользователь ") + token + " был создан";
}

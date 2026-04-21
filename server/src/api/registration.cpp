#include <sodium.h>
#include <string>
#include <vector>

#include "api/registration.hpp"
#include "services/database.hpp"
#include "services/string_handler.hpp"
#include "services/jwt.hpp"

Registration::Registration(const std::vector<std::string>& user) {
    const std::string& email = user[0];
    const std::string& password = user[1];
    const Database database;

    if (const auto error = email_check(email)) {
        response = *error;
        return;
    }

    for (const std::string& input : user) {
        if (const auto error = length_check(input, 8, 64)) {
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

    std::vector<std::string> data_hashed = user;
    data_hashed[1] = hashed_password;

    if (!database.add_user(data_hashed)) {
        response = "Не удалось добавить пользователя в базу данных";
        return;
    }

    const std::string token = Jwt::create_token(email);
    response = token;
}

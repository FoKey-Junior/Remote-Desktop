#include <sodium.h>
#include <string>
#include <vector>

#include "api/authentication.hpp"
#include "services/database.hpp"
#include "services/string_handler.hpp"
#include "services/jwt.hpp"

Result Authentication::registration(const std::vector<std::string>& user) {
    const Database database;
    Result result;

    if (user.size() != 2) {
        result.response = "Ошибка: отсутствует email или пароль";
        result.status = 400;
        return result;
    }

    const std::string& email = user[0];
    const std::string& password = user[1];

    if (const auto error = email_check(email)) {
        result.response = *error;
        result.status = 400;
        return result;
    }

    for (const std::string& input : user) {
        if (const auto error = length_check(input, 8, 64)) {
            result.response = *error;
            result.status = 422;
            return result;
        }
    }

    if (!database.uniqueness_check(email)) {
        result.response = "Пользователь с таким именем уже существует";
        result.status = 409;
        return result;
    }

    char hashed_password[crypto_pwhash_STRBYTES];
    if (crypto_pwhash_str(
            hashed_password,
            password.c_str(),
            password.size(),
            crypto_pwhash_OPSLIMIT_INTERACTIVE,
            crypto_pwhash_MEMLIMIT_INTERACTIVE) != 0) {
        result.response = "Ошибка хеширования пароля";
        result.status = 400;
        return result;
    }

    std::vector<std::string> data_hashed = user;
    data_hashed[1] = hashed_password;

    if (!database.add_user(data_hashed)) {
        result.response = "Не удалось добавить пользователя в базу данных";
        result.status = 400;
        return result;
    }

    result.response = Jwt::create_token(email);
    return result;
}
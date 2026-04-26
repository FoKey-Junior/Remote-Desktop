#include <sodium.h>
#include <string>
#include <vector>

#include "api/authentication.hpp"
#include "services/database.hpp"
#include "services/string_handler.hpp"
#include "services/jwt.hpp"

using namespace std::chrono;

Result Authentication::authorization(const std::vector<std::string>& user) {
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

    std::string stored_hash;

    if (!database.get_password_hash(email, stored_hash)) {
        result.response = "Пользователь с таким именем не существует";
        result.status = 404;
        return result;
    }

    if (crypto_pwhash_str_verify(
            stored_hash.c_str(),
            password.c_str(),
            password.size()) != 0) {
        result.response = "Неверный пароль";
        result.status = 401;
        return result;
    }

    result.response = Jwt::create_token(email);
    return result;
}
#include <sodium.h>
#include <string>
#include <vector>

#include "api/Authorization.hpp"
#include "services/Database.hpp"
#include "services/StringHandler.hpp"
#include "services/JWT.hpp"

using namespace std::chrono;

Authorization::Authorization(const std::vector<std::string>& user) {
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

    if (sodium_init() < 0) {
        response = "Ошибка инициализации криптобиблиотеки";
        return;
    }

    std::string stored_hash;

    if (!database.get_password_hash(email, stored_hash)) {
        response = "Пользователь с таким именем не существует";
        return;
    }

    if (crypto_pwhash_str_verify(
            stored_hash.c_str(),
            password.c_str(),
            password.size()) != 0) {
        response = "Неверный пароль";
        return;
    }

    const std::string token = JWT::create_token(email);
    response = token;
}

#include <jwt-cpp/jwt.h>
#include <sodium.h>
#include <iostream>
#include <string>
#include <vector>
#include <memory>

#include "../../include/api/Authorization.hpp"
#include "../../include/JwtService.hpp"
#include "../../include/Database.hpp"
#include "../../include/StringUtils.hpp"

using namespace std::chrono;

Authorization::Authorization(const std::vector<std::string>& user_) {
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

    std::string token = JwtService::create_token(email);
    response = "ваш токен: " + token;
}

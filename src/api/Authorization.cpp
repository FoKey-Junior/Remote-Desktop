#include <jwt-cpp/jwt.h>
#include <sodium.h>
#include <iostream>
#include <string>
#include <vector>

#include "../../include/api/Authorization.hpp"
#include "../../include/Database.hpp"
#include "../../include/StringUtils.hpp"

Authorization::Authorization(const std::vector<std::string>& data_user) {
    if (auto error = email_check(data_user[0])) {
        response = *error;
        return;
    }

    for (const std::string& input : data_user) {
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
    Database database("dbname=postgres user=postgres password=1234 host=postgres_cpp port=5432");

    if (!database.get_password_hash(data_user[0], stored_hash)) {
        response = "Пользователь с таким именем не существует";
        return;
    }

    if (crypto_pwhash_str_verify(
            stored_hash.c_str(),
            data_user[1].c_str(),
            data_user[1].size()) != 0) {
        response = "Неверный пароль";
        return;
            }

    auto token = jwt::create()
    .set_type("JWS")
    .set_issuer("auth0")
    .set_payload_claim("sample", jwt::claim(std::string("test")))
    .sign(jwt::algorithm::hs256{"secret"});

    response = "Вы вошли в аккаунт";
}

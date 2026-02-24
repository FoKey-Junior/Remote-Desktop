#include <jwt-cpp/jwt.h>
#include <sodium.h>
#include <iostream>
#include <string>
#include <vector>

#include "../../include/api/Authorization.hpp"
#include "../../include/Database.hpp"
#include "../../include/StringUtils.hpp"

using namespace std::chrono;

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


    auto now = system_clock::now();
    auto exp = now + hours(24);
    const char* secret_env = std::getenv("JWT_SECRET");

    if (!secret_env) {
        response = "JWT secret not configured";
        return;
    }

    std::string secret(secret_env);

    auto token = jwt::create()
        .set_issuer("postgres_cpp_server")
        .set_subject(data_user[0])
        .set_issued_at(now)
        .set_expires_at(exp)
        .sign(jwt::algorithm::hs256{ secret });

    response = "Вы вошли в аккаунт, ваш токен: " + token;
}

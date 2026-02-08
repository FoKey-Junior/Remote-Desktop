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
        if (auto error = length_check(input, 8, 25)) {
            response = *error;
            return;
        }
    }

    Database database("dbname=postgres user=postgres password=1234 hostaddr=127.0.0.1 port=5438");
    if (!database.uniqueness_check(data_user[0])) {
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
            data_user[1].c_str(),
            data_user[1].size(),
            crypto_pwhash_OPSLIMIT_INTERACTIVE,
            crypto_pwhash_MEMLIMIT_INTERACTIVE) != 0) {
        response = "Ошибка хеширования пароля";
        return;
    }

    std::vector<std::string> data_hashed = data_user;
    data_hashed[1] = hashed_password;

    database.add_row(data_hashed);
    response = "Новый пользователь был создан";
}


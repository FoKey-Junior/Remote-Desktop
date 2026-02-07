#include "../../include/api/Registration.hpp"
#include "../../include/Database.hpp"
#include "../../include/StringUtils.hpp"
#include <iostream>
#include <string>
#include <vector>

using namespace std;

Registration::Registration(const std::vector<std::string>& data_user) {
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
    database.add_row(data_user);

    response = "Новый пользователь был создан";
}


#include "../../include/api/Registration.hpp"
#include "../../include/Database.hpp"
#include <iostream>
#include <string>
#include <vector>

using namespace std;

Registration::Registration(const std::vector<std::string>& data_user) {
    Database database("dbname=postgres user=postgres password=1234 hostaddr=127.0.0.1 port=5438");
    database.add_row(data_user);

    response = "Новый пользователь был создан";
}


#include <iostream>
#include "../include/Database.hpp"

using namespace pqxx;
using namespace std;

Database::Database(const std::string& connection_data) : connect(connection_data) {
    try {
        pqxx::work bd(connect);
        bd.exec("SELECT 1");
        bd.commit();
    } catch (const std::exception &e) {
        cerr << e.what() << std::endl;
    }
}

bool Database::add_user(const std::vector<std::string>& data) {
    if (data.size() < 2)
        throw std::invalid_argument("Not enough data");

    pqxx::work db(connect);

    pqxx::result r = db.exec_params(
        "INSERT INTO user_accounts (email, password_hash) "
        "VALUES ($1, $2) "
        "ON CONFLICT (email) DO NOTHING "
        "RETURNING id;",
        data[0], data[1]
    );

    db.commit();

    return !r.empty();
}

bool Database::uniqueness_check(const std::string& email) {
    pqxx::work db(connect);
    pqxx::result r = db.exec_params(
        "SELECT 1 FROM user_accounts WHERE email = $1 LIMIT 1",
        email
    );

    return r.empty();
}

bool Database::get_password_hash(const std::string& email, std::string& out_hash) {
    pqxx::work db(connect);
    pqxx::result r = db.exec_params(
        "SELECT password_hash FROM user_accounts WHERE email = $1 LIMIT 1",
        email
    );

    if (r.empty()) {
        return false;
    }

    out_hash = r[0][0].as<std::string>();
    return true;
}

bool Database::add_command(int id_user, std::string &command) {
    pqxx::work db(connect);

    pqxx::result r = db.exec_params(
        "UPDATE user_commands "
        "SET command = ARRAY[$1] || command "
        "WHERE id = $2 "
        "RETURNING id;",
        word,
        id_user
    );

    db.commit();

    return !r.empty();
}

std::string& Database::get_command() {
    pqxx::work db(connect);
    pqxx::result r = db.exec_params(
    "SELECT command[1] "
    "FROM user_commands "
    "WHERE id = $1;",
    id
);

    if (r.empty() || r[0][0].is_null()) {
        return "";
    }

    return r[0][0].c_str();
}

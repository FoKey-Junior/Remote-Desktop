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

bool Database::add_row(const std::vector<std::string>& data) {
    if (data.size() < 2)
        throw std::invalid_argument("Not enough data");

    pqxx::work db(connect);

    pqxx::result r = db.exec(
        "INSERT INTO users (login, password) "
        "VALUES ($1, $2) "
        "ON CONFLICT (login) DO NOTHING "
        "RETURNING id;",
        pqxx::params{ data[0], data[1] }
    );

    db.commit();

    return !r.empty();
}

bool Database::uniqueness_check(const std::string& login) {
    pqxx::work db(connect);
    pqxx::result r = db.exec(
        "SELECT 1 FROM users WHERE login = $1 LIMIT 1",
        pqxx::params{login}
    );

    return r.empty();
}

bool Database::get_password_hash(const std::string& login, std::string& out_hash) {
    pqxx::work db(connect);
    pqxx::result r = db.exec(
        "SELECT password FROM users WHERE login = $1 LIMIT 1",
        pqxx::params{login}
    );

    if (r.empty()) {
        return false;
    }

    out_hash = r[0][0].as<std::string>();
    return true;
}

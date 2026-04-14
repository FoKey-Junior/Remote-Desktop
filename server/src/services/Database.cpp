#include <iostream>
#include <memory>
#include <pqxx/pqxx>
#include "services/Database.hpp"

Database::Database() {
    try {
        connect = std::make_unique<pqxx::connection>(
            "dbname=postgres user=postgres password=1234 host=localhost port=5432 connect_timeout=3"
        );

        status_db = connect->is_open();
        if (status_db) std::cout << "DB connected\n";
    } catch (...) {
        status_db = false;
    }
}

bool Database::add_user(const std::vector<std::string>& data) {
    if (data.size() < 2 || data[0].empty() || data[1].empty()) return false;

    pqxx::work db(*connect);
    auto r = db.exec(
        "INSERT INTO user_accounts (email, password_hash) VALUES ($1,$2) "
        "ON CONFLICT (email) DO NOTHING RETURNING email;",
        pqxx::params{data[0], data[1]}
    );
    db.commit();
    return !r.empty();
}

bool Database::uniqueness_check(const std::string& email_user) {
    if (email_user.empty()) return false;

    pqxx::work db(*connect);
    auto r = db.exec(
        "SELECT 1 FROM user_accounts WHERE email=$1 LIMIT 1;",
        pqxx::params{email_user}
    );

    return r.empty();
}

bool Database::get_password_hash(const std::string& email_user, std::string& out_hash) {
    if (email_user.empty()) return false;

    pqxx::work db(*connect);
    auto r = db.exec(
        "SELECT password_hash FROM user_accounts WHERE email=$1 LIMIT 1;",
        pqxx::params{email_user}
    );

    if (r.empty() || r[0][0].is_null()) return false;
    out_hash = r[0][0].as<std::string>();
    return true;
}

bool Database::add_command(const std::string& email_user, const std::string& command) {
    if (email_user.empty() || command.empty()) return false;

    pqxx::work db(*connect);
    auto r = db.exec(
        "UPDATE user_accounts SET commands=array_prepend($1,commands) "
        "WHERE email=$2 RETURNING email;",
        pqxx::params{command, email_user}
    );

    db.commit();
    return !r.empty();
}

bool Database::delete_command(const std::string& email_user) {
    if (email_user.empty()) return false;

    pqxx::work db(*connect);
    auto r = db.exec(
        "UPDATE user_accounts SET commands="
        "CASE WHEN array_length(commands,1)>1 "
        "THEN commands[2:array_length(commands,1)] ELSE '{}' END "
        "WHERE email=$1 RETURNING email;",
        pqxx::params{email_user}
    );

    db.commit();
    return !r.empty();
}

std::string Database::get_command(const std::string& email_user) {
    if (email_user.empty()) return "";

    pqxx::work db(*connect);
    auto r = db.exec(
        "SELECT commands[1] FROM user_accounts WHERE email=$1;",
        pqxx::params{email_user}
    );

    if (r.empty() || r[0][0].is_null()) return "";
    return r[0][0].as<std::string>();
}
#include <memory>
#include <pqxx/pqxx>
#include "yaml-cpp/yaml.h"

#include "services/database.hpp"

Database::Database() {
    try {
        YAML::Node config = YAML::LoadFile("configs.yaml");
        auto postgres_data = config["postgres"];

        const auto db_name = postgres_data["name"].as<std::string>();
        const auto db_user = postgres_data["user"].as<std::string>();
        const auto db_host = postgres_data["host"].as<std::string>();
        const auto db_password = postgres_data["password"].as<std::string>();

        const int db_port = postgres_data["port"].as<int>();
        const int db_connect_timeout = postgres_data["connect_timeout"].as<int>();

        std::string conn_str =
            "dbname=" + db_name +
            " user=" + db_user +
            " password=" + db_password +
            " host=" + db_host +
            " port=" + std::to_string(db_port) +
            " connect_timeout=" + std::to_string(db_connect_timeout);

        connect = std::make_unique<pqxx::connection>(conn_str);
        status_db = connect->is_open();
    } catch (...) {
        status_db = false;
    }
}

bool Database::add_user(const std::vector<std::string>& data) const {
    if (data.size() < 2 || data[0].empty() || data[1].empty()) return false;

    pqxx::work db(*connect);
    const auto result = db.exec(
        "INSERT INTO user_accounts (email, password_hash) VALUES ($1,$2) "
        "ON CONFLICT (email) DO NOTHING RETURNING email;",
        pqxx::params{data[0], data[1]}
    );
    db.commit();
    return !result.empty();
}

bool Database::uniqueness_check(const std::string& email_user) const {
    if (email_user.empty()) return false;

    pqxx::work db(*connect);
    const auto result = db.exec(
        "SELECT 1 FROM user_accounts WHERE email=$1 LIMIT 1;",
        pqxx::params{email_user}
    );

    return result.empty();
}

bool Database::get_password_hash(const std::string& email_user, std::string& out_hash) const {
    if (email_user.empty()) return false;

    pqxx::work db(*connect);
    const auto result = db.exec(
        "SELECT password_hash FROM user_accounts WHERE email=$1 LIMIT 1;",
        pqxx::params{email_user}
    );

    if (result.empty() || result[0][0].is_null()) return false;
    out_hash = result[0][0].as<std::string>();
    return true;
}

bool Database::add_command(const std::string& email_user, const std::string& command) const {
    if (email_user.empty() || command.empty()) return false;

    pqxx::work db(*connect);
    const auto result = db.exec(
        "UPDATE user_accounts SET commands=array_prepend($1,commands) "
        "WHERE email=$2 RETURNING email;",
        pqxx::params{command, email_user}
    );

    db.commit();
    return !result.empty();
}

bool Database::delete_command(const std::string& email_user) const {
    if (email_user.empty()) return false;

    pqxx::work db(*connect);
    const auto result = db.exec(
        "UPDATE user_accounts SET commands="
        "CASE WHEN array_length(commands,1)>1 "
        "THEN commands[2:array_length(commands,1)] ELSE '{}' END "
        "WHERE email=$1 RETURNING email;",
        pqxx::params{email_user}
    );

    db.commit();
    return !result.empty();
}

std::string Database::get_command(const std::string& email_user) const {
    if (email_user.empty()) return "";

    pqxx::work db(*connect);
    const auto result = db.exec(
        "SELECT commands[1] FROM user_accounts WHERE email=$1;",
        pqxx::params{email_user}
    );

    if (result.empty() || result[0][0].is_null()) return "";
    return result[0][0].as<std::string>();
}

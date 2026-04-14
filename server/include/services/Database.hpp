#ifndef REMOTE_DESKTOP_DB_H
#define REMOTE_DESKTOP_DB_H

#include <pqxx/pqxx>
#include <vector>
#include <string>
#include <memory>

class Database {
    std::unique_ptr<pqxx::connection> connect;
    bool status_db = false;

public:
    Database();
    bool get_status_db() const { return status_db; }

    bool add_user(const std::vector<std::string>& data);
    bool uniqueness_check(const std::string& email_user);
    bool get_password_hash(const std::string& email_user, std::string& out_hash);

    bool add_command(const std::string& email_user, const std::string& command);
    bool delete_command(const std::string& email_user);
    std::string get_command(const std::string& email_user);
};

#endif
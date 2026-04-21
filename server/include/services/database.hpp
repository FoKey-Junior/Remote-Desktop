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
    [[nodiscard]] bool get_status_db() const { return status_db; }

    [[nodiscard]] bool add_user(const std::vector<std::string>& data) const;
    [[nodiscard]] bool uniqueness_check(const std::string& email_user) const;
    [[nodiscard]] bool get_password_hash(const std::string& email_user, std::string& out_hash) const;

    [[nodiscard]] bool add_command(const std::string& email_user, const std::string& command) const;
    [[nodiscard]] bool delete_command(const std::string& email_user) const;
    [[nodiscard]] std::string get_command(const std::string& email_user) const;
};

#endif
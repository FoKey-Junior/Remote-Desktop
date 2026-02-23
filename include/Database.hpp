#ifndef REMOTE_DESKTOP_DB_H
#define REMOTE_DESKTOP_DB_H


#include <pqxx/pqxx>
#include <vector>
#include <string>

class Database {
    pqxx::connection connect;

public:
    Database(const std::string& connection_data);

    bool add_user(const std::vector<std::string>& data);
    bool uniqueness_check(const std::string& email);
    bool get_password_hash(const std::string& email, std::string& out_hash);

    bool add_command(int id_user, const std::string& command);
    bool delete_command(int id_user);
    std::string get_command(int id_user);
};


#endif

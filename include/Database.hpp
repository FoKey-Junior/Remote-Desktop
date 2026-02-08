#ifndef REMOTE_DESKTOP_DB_H
#define REMOTE_DESKTOP_DB_H


#include <pqxx/pqxx>
#include <vector>
#include <string>

class Database {
    pqxx::connection connect;

public:
    Database(const std::string& connection_data);
    bool add_row(const std::vector<std::string>& data);
    bool uniqueness_check(const std::string& email);
    bool get_password_hash(const std::string& email, std::string& out_hash);
};


#endif

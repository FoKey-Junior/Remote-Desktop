#ifndef REMOTE_DESKTOP_DB_H
#define REMOTE_DESKTOP_DB_H


#include <pqxx/pqxx>
#include <vector>
#include <string>

class Database {
    pqxx::connection connect;

public:
    Database(const std::string& connection_data_);
    bool add_row(const std::vector<std::string>& data_);
    bool uniqueness_check(const std::string& login_);
};


#endif

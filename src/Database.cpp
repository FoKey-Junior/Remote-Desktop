#include <iostream>
#include "../include/Database.hpp"

using namespace pqxx;
using namespace std;

Database::Database(const std::string& connection_data_) : connect(connection_data_) {
    try {
        pqxx::work bd(connect);
        bd.exec("SELECT 1");
        bd.commit();
    } catch (const std::exception &e) {
        cerr << e.what() << std::endl;
    }
}

Database::~Database() {
}

bool Database::add_row(const std::vector<std::string>& data_)
{
    if (data_.size() < 2)
        throw std::invalid_argument("Not enough data");

    pqxx::work db(connect);

    pqxx::result r = db.exec(
        "INSERT INTO users (login, password) "
        "VALUES ($1, $2) "
        "ON CONFLICT (login) DO NOTHING "
        "RETURNING id;",
        pqxx::params{ data_[0], data_[1] }
    );

    db.commit();

    return !r.empty();
}

void Database::delete_row(int id_) {

}

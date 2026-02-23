#include "crow.h"
#include <vector>
#include <string>

#include "../../include/api/Router.hpp"
#include "../../include/Database.hpp"
#include "../../include/api/Registration.hpp" 
#include "../../include/api/Authorization.hpp"

void Router::start_server(int port_server_) {
    Database database("dbname=postgres user=postgres password=1234 host=postgres_cpp port=5432");
    port_server = port_server_;
    crow::SimpleApp app;

    CROW_ROUTE(app, "/api")([]() {
        return "The server is working properly";
    });

    CROW_ROUTE(app, "/api/registration").methods("POST"_method)([](const crow::request& req) { 
        auto x = crow::json::load(req.body);

        if (!x)
            return crow::response(400);

        std::string email = x["email"].s();
        std::string password = x["password"].s();
        std::vector<std::string> data_user = {email, password};

        Registration registration(data_user);
        return crow::response{registration.get_response()};
    });

    CROW_ROUTE(app, "/api/authorization").methods("POST"_method)([](const crow::request& req) { 
        auto x = crow::json::load(req.body);

        if (!x)
            return crow::response(400);

        std::string email = x["email"].s();
        std::string password = x["password"].s();
        std::vector<std::string> data_user = {email, password};

        Authorization authorization(data_user);
        return crow::response{authorization.get_response()};
    });

    CROW_ROUTE(app, "/api/new_command").methods("POST"_method)([&database](const crow::request& req) {
        auto x = crow::json::load(req.body);

        if (!x || !x.has("id") || !x.has("command"))
            return crow::response(400);

        int id = x["id"].i();
        std::string command = x["command"].s();

        return crow::response{
            database.add_command(id, command) ? 200 : 400
        };
    });

    CROW_ROUTE(app, "/api/delete_command").methods("POST"_method)([&database](const crow::request& req) {
        auto x = crow::json::load(req.body);

        if (!x || !x.has("id"))
            return crow::response(400);

        int id = x["id"].i();

        return crow::response{
              database.delete_command(id) ? 200 : 400
        };
    });

    CROW_ROUTE(app, "/api/get_command").methods("POST"_method)([&database](const crow::request& req) {
        auto x = crow::json::load(req.body);

        if (!x || !x.has("id"))
            return crow::response(400);

        int id = x["id"].i();

        return crow::response{ database.get_command(id) };
    });

    app.port(port_server).run();
}

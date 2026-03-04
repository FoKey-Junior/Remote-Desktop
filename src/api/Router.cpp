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
        return crow::response(200, "Server is working properly");
    });

    CROW_ROUTE(app, "/api/registration").methods("POST"_method)([](const crow::request& req) {
        auto x = crow::json::load(req.body);
        if (!x || !x.has("email") || !x.has("password") ||
            x["email"].t() != crow::json::type::String ||
            x["password"].t() != crow::json::type::String)
            return crow::response(400, "Invalid JSON");

        std::vector<std::string> data_user{x["email"].s(), x["password"].s()};
        Registration registration(data_user);
        return crow::response(200, registration.get_response());
    });

    CROW_ROUTE(app, "/api/authorization").methods("POST"_method)([](const crow::request& req) {
        auto x = crow::json::load(req.body);
        if (!x || !x.has("email") || !x.has("password") ||
            x["email"].t() != crow::json::type::String ||
            x["password"].t() != crow::json::type::String)
            return crow::response(400, "Invalid JSON");

        std::vector<std::string> data_user{x["email"].s(), x["password"].s()};
        Authorization authorization(data_user);
        return crow::response(200, authorization.get_response());
    });

    CROW_ROUTE(app, "/api/new_command").methods("POST"_method)([&database](const crow::request& req) {
        auto x = crow::json::load(req.body);
        if (!x || !x.has("id") || !x.has("command") ||
            x["id"].t() != crow::json::type::Number ||
            x["command"].t() != crow::json::type::String)
            return crow::response(400);
        return crow::response(database.add_command(x["id"].i(), x["command"].s()) ? 201 : 500);
    });

    CROW_ROUTE(app, "/api/delete_command").methods("POST"_method)([&database](const crow::request& req) {
        auto x = crow::json::load(req.body);
        if (!x || !x.has("id") || x["id"].t() != crow::json::type::Number)
            return crow::response(400);
        return crow::response(database.delete_command(x["id"].i()) ? 200 : 404);
    });

    CROW_ROUTE(app, "/api/get_command").methods("POST"_method)([&database](const crow::request& req) {
        auto x = crow::json::load(req.body);
        if (!x || !x.has("id") || x["id"].t() != crow::json::type::Number)
            return crow::response(400);
        auto result = database.get_command(x["id"].i());
        return result ? crow::response(200, *result) : crow::response(404);
    });

    app.port(port_server).multithreaded().run();
}
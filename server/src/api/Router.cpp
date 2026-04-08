#include "crow.h"
#include <vector>
#include <string>
#include <memory>
#include <optional>

#include "api/Router.hpp"
#include "api/Registration.hpp"
#include "api/Authorization.hpp"
#include "services/Database.hpp"

namespace {
    std::optional<std::vector<std::string>> parse_user(const crow::request& req) {
        auto body = crow::json::load(req.body);
        if (!body || !body.has("email") || !body.has("password")) return std::nullopt;
        if (body["email"].t() != crow::json::type::String || body["password"].t() != crow::json::type::String) return std::nullopt;

        return std::vector<std::string>	{
		    body["email"].s(), body["password"].s()
	    };
    }
}

void Router::start_server(int port_server_) {
    port_server = port_server_;
    crow::SimpleApp app;
    Database database;

    CROW_ROUTE(app, "/api").methods("GET"_method)([]() { return crow::response(200, "Server is working properly"); });

    CROW_ROUTE(app, "/api/registration").methods("POST"_method)([](const crow::request& req) {
        auto data = parse_user(req);
        if (!data) return crow::response(400);

        try {
            Registration registration(*data);
            return crow::response(200, registration.get_response());
        } catch (const std::exception& e) {
            std::cerr << "Registration failed: " << e.what() << std::endl;
            return crow::response(500);
        }
    });

    CROW_ROUTE(app, "/api/authorization").methods("POST"_method)([](const crow::request& req) {
        auto data = parse_user(req);
        if (!data) return crow::response(400);

        try {
            Authorization authorization(*data);
            return crow::response(200, authorization.get_response());
        } catch (const std::exception& e) {
            std::cerr << "Authorization failed: " << e.what() << std::endl;
            return crow::response(500);
        }
    });

    CROW_ROUTE(app, "/api/new_command").methods("POST"_method)([&database](const crow::request& req) {
        auto body = crow::json::load(req.body);

        if (!body ||
            !body.has("id") || body["id"].t() != crow::json::type::Number ||
            !body.has("command") || body["command"].t() != crow::json::type::String ||
            !body.has("token") || body["token"].t() != crow::json::type::String)
            return crow::response(400);

        return crow::response(database.add_command(body["id"].i(), body["command"].s()) ? 201 : 500);
    });

    CROW_ROUTE(app, "/api/delete_command").methods("POST"_method)([&database](const crow::request& req) {
        auto body = crow::json::load(req.body);

        if (!body ||
            !body.has("id") || body["id"].t() != crow::json::type::Number ||
            !body.has("command") || body["command"].t() != crow::json::type::String ||
            !body.has("token") || body["token"].t() != crow::json::type::String)
            return crow::response(400);

        return crow::response(database.delete_command(body["id"].i()) ? 200 : 404);
    });

    CROW_ROUTE(app, "/api/get_command").methods("POST"_method)([&database](const crow::request& req) {
        auto body = crow::json::load(req.body);

        if (!body ||
            !body.has("id") || body["id"].t() != crow::json::type::Number ||
            !body.has("command") || body["command"].t() != crow::json::type::String ||
            !body.has("token") || body["token"].t() != crow::json::type::String)
            return crow::response(400);

        auto result = database.get_command(body["id"].i());
        return result.empty() ? crow::response(404) : crow::response(200, result);
    });

    app.port(port_server).multithreaded().run();
}
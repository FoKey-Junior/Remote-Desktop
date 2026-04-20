#include "crow.h"
#include <vector>
#include <string>
#include <memory>
#include <optional>
#include <iostream>

#include "api/router.hpp"
#include "api/registration.hpp"
#include "api/authorization.hpp"
#include "services/database.hpp"
#include "services/jwt.hpp"

namespace {
    std::optional<std::vector<std::string>> parse_user(const crow::request& req) {
        const auto body = crow::json::load(req.body);
        if (!body || !body.has("email") || !body.has("password")) return std::nullopt;
        if (body["email"].t() != crow::json::type::String || body["password"].t() != crow::json::type::String) return std::nullopt;

        return std::vector<std::string>	{
		    body["email"].s(), body["password"].s()
	    };
    }
}

void router::start_server(int port_server) {
    crow::SimpleApp app;

    auto database = std::make_shared<database>();
    auto jwt = std::make_shared<jwt>();

    if (!database->get_status_db()) {
        std::cerr << "DB unavailable, running in degraded mode\n";
    }

    CROW_ROUTE(app, "/api").methods("GET"_method)([]() { return crow::response(200, "Server is working properly"); });

    CROW_ROUTE(app, "/api/registration").methods("POST"_method)([](const crow::request& req) {
        const auto data = parse_user(req);
        if (!data) return crow::response(400);

        try {
            registration registration(*data);
            return crow::response(200, registration.get_response());
        } catch (const std::exception& e) {
            std::cerr << "Registration failed: " << e.what() << std::endl;
            return crow::response(500);
        }
    });

    CROW_ROUTE(app, "/api/authorization").methods("POST"_method)([](const crow::request& req) {
        const auto data = parse_user(req);
        if (!data) return crow::response(400);

        try {
            authorization authorization(*data);
            return crow::response(200, authorization.get_response());
        } catch (const std::exception& e) {
            std::cerr << "Authorization failed: " << e.what() << std::endl;
            return crow::response(500);
        }
    });

    CROW_ROUTE(app, "/api/new_command").methods("POST"_method)([&database, &jwt](const crow::request& req) {
        const auto body = crow::json::load(req.body);

        if (!body ||
            !body.has("token") || body["token"].t() != crow::json::type::String ||
            !body.has("command") || body["command"].t() != crow::json::type::String) {
            return crow::response(400);
        }

        return crow::response(database->add_command(jwt->verification_token(body["token"].s()), body["command"].s()) ? 201 : 500);
    });

    CROW_ROUTE(app, "/api/delete_command").methods("POST"_method)([&database, &jwt](const crow::request& req) {
        const auto body = crow::json::load(req.body);

        if (!body ||!body.has("token") || body["token"].t() != crow::json::type::String) {
            return crow::response(400);
        }

        return crow::response(database->delete_command(jwt->verification_token(body["token"].s())) ? 200 : 404);
    });

    CROW_ROUTE(app, "/api/get_command").methods("POST"_method)([&database, &jwt](const crow::request& req) {
        const auto body = crow::json::load(req.body);

        if (!body || !body.has("token") || body["token"].t() != crow::json::type::String) {
            return crow::response(400);
        }

        const auto result = database->get_command(jwt->verification_token(body["token"].s()));
        return result.empty() ? crow::response(404) : crow::response(200, result);
    });

    app.port(port_server).multithreaded().run();
}

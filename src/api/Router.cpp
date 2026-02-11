#include "crow.h"
#include <vector>
#include <string>

#include "../../include/api/Router.hpp"
#include "../../include/api/Registration.hpp" 
#include "../../include/api/Authorization.hpp"

void Router::start_server(int port_server_) {
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

    CROW_ROUTE(app, "/api/send_command").methods("POST"_method)([](const crow::request& req) { 
        auto x = crow::json::load(req.body);

        if (!x)
            return crow::response(400);
        
        return crow::response{x};
    });

    CROW_ROUTE(app, "/api/get_command").methods("POST"_method)([](const crow::request& req) { 
        auto x = crow::json::load(req.body);

        if (!x)
            return crow::response(400);
        
        return crow::response{x};
    });

    app.port(port_server).run();
}

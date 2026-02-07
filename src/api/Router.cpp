#include "crow.h"
#include <vector>
#include <string>
#include "../../include/api/Router.hpp"
#include "../../include/api/Registration.hpp" 

void Router::start_server(int port_server_) {
    port_server = port_server_;
    crow::SimpleApp app;

    CROW_ROUTE(app, "/api")([]() {
        return "The server is working properly";
    });

    CROW_ROUTE(app, "/api/add_json").methods("POST"_method)([](const crow::request& req) { 
        auto x = crow::json::load(req.body);

        if (!x)
            return crow::response(400);

        std::string login = x["login"].s();
        std::string password = x["password"].s();
        std::vector<std::string> data_user = {login, password};

        Registration registration(data_user);
        return crow::response{registration.get_response()};
    });

    app.port(port_server).run();
}

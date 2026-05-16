#include <iostream>
#include <exception>
#include "yaml-cpp/yaml.h"

#include "api/router.hpp"

int main() {
    try {
        YAML::Node config = YAML::LoadFile("configs.yaml");
        const auto server_data = config["server"];
        const int port = server_data["port"].as<int>();

        std::cout << "start http server http://localhost:" << port << "/api" << std::endl;
        Router::start_server(port);
    }
    catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}

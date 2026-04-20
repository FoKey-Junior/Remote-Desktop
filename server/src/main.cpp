#include <iostream>
#include <exception>
#include "yaml-cpp/yaml.h"

#include "api/router.hpp"

int main() {
    try {
        YAML::Node config = YAML::LoadFile("configs.yaml");
        auto server_data = config["server"];
        int port = server_data["port"].as<int>();

        router router;
        std::cout << "start http server http://localhost:" << port << "/api" << std::endl;
        router.start_server(port);
    }
    catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}

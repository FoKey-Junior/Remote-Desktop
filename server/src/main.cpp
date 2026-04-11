#include <iostream>
#include <exception>
#include "api/Router.hpp"

int main() {
    int port = 4000;

    try {
        Router router;
        std::cout << "start http server http://localhost:" << port << "/api" << std::endl;
        router.start_server(port);
    }
    catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}

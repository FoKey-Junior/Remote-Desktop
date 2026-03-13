#include "../include/api/Router.hpp"
#include <iostream>

int main() {
    try {
        Router router;
        router.start_server(8080);
    }
    catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}
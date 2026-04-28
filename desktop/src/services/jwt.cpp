#include "fstream"
#include "services/jwt.h"

void Jwt::save_token(const std::string& token) {
    std::ofstream file("data.bin");
    file << token;
}

std::string Jwt::get_token() {
    std::ifstream file("data.bin");
    std::string token;

    if (file.is_open()) {
        if (!std::getline(file, token)) {
            return "";
        }

        file.close();
    } else {
        return "";
    }

    return token;
}
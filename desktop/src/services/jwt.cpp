#include <fstream>
#include <string>

#include "services/jwt.h"

void Jwt::save_token(const std::string& token) {
    std::ofstream file("data.bin");
    file << token;
}

std::string Jwt::get_token() {
    std::ifstream file_contents("data.bin");

    if (file_contents.is_open()) {
        std::string line_contents;
        if (std::getline(file_contents, line_contents)) { return line_contents; }
    }

    return "";
}
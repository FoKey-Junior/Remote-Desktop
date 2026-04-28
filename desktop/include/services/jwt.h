#pragma once

#include <string>

class Jwt {
public:
    static void save_token(const std::string& token);
    static std::string get_token();
};
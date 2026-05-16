#pragma once

#include <jwt-cpp/jwt.h>
#include <string>


class Jwt {
    public:
    static std::string create_token(const std::string& email);
    static std::string verification_token(const std::string& token);
};
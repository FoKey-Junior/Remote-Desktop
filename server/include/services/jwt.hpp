#ifndef REMOTE_DESKTOP_JWTSERVICE_H
#define REMOTE_DESKTOP_JWTSERVICE_H

#include <jwt-cpp/jwt.h>
#include <string>


class Jwt {
    public:
    static std::string create_token(const std::string& email);
    static std::string verification_token(const std::string& token);
};


#endif
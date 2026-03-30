#ifndef REMOTE_DESKTOP_JWTSERVICE_H
#define REMOTE_DESKTOP_JWTSERVICE_H

#include <jwt-cpp/jwt.h>
#include <string>


class JWT {
    public:
    static std::string create_token(std::string& email);
    static std::string verification_token(std::string& token);
};


#endif
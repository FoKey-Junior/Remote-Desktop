#ifndef REMOTE_DESKTOP_JWTSERVICE_H
#define REMOTE_DESKTOP_JWTSERVICE_H

#include <jwt-cpp/jwt.h>
#include <string>


class JwtService {
    public:
    static std::string create_token(std::string email_);
};


#endif
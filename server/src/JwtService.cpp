#include "../include/JwtService.hpp"

std::string JwtService::create_token(std::string& email) {
    auto token = jwt::create()
        .set_type("JWS")
        .set_issuer("auth0")
        .set_payload_claim("email", jwt::claim(std::string(email)))
        .sign(jwt::algorithm::hs256{"secret"});

    return token;
}

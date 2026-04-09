#include "services/JWT.hpp"

std::string JWT::create_token(const std::string& email) {
    auto token = jwt::create()
        .set_type("JWS")
        .set_issuer("auth0")
        .set_payload_claim("email", jwt::claim(std::string(email)))
        .sign(jwt::algorithm::hs256{"secret"});

    return token;
}

std::string verification_token(const std::string& token) {
    auto verifier = jwt::verify()
        .allow_algorithm(jwt::algorithm::hs256{"secret"})
        .with_issuer("auth0");

    auto decoded = jwt::decode(token);
    verifier.verify(decoded);

    std::string email = decoded.get_payload_claim("email").as_string();
    return email;
}
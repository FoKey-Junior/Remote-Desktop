#include "fstream"
#include "services/jwt.h"
using namespace std;

void Jwt::save_token(const string& token)
{
    std::ofstream file("data.bin");
    file << token;
}
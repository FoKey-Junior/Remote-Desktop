#pragma once

#include <string>
#include <vector>

struct Result {
  int status = 200;
  std::string response;
};

class Authentication {
  public:
  [[nodiscard]] Result authorization (const std::vector<std::string>& user);
  [[nodiscard]] Result registration (const std::vector<std::string>& user);
};
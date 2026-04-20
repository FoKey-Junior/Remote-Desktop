#ifndef REMOTE_DESKTOP_AUTHORIZATION_H
#define REMOTE_DESKTOP_AUTHORIZATION_H


#include <string>
#include <vector>

class authorization {
  std::string response;

  public:
  authorization(const std::vector<std::string>& user);
  std::string get_response() { return response; };
};


#endif

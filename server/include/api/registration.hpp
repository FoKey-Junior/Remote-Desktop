#ifndef REMOTE_DESKTOP_REGISTRATION_H
#define REMOTE_DESKTOP_REGISTRATION_H


#include <string>
#include <vector>

class registration {
  std::string response;

  public:
  registration(const std::vector<std::string>& user);
  std::string get_response() { return response; };
};


#endif

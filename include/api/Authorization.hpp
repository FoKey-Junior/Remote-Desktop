#ifndef REMOTE_DESKTOP_AUTHORIZATION_H
#define REMOTE_DESKTOP_AUTHORIZATION_H


#include <string>
#include <vector>

class Authorization {
  std::string response;

  public:
  Authorization(const std::vector<std::string>& data_user);
  std::string get_response() { return response; };
};


#endif

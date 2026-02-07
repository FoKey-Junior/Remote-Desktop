#ifndef REMOTE_DESKTOP_REGISTRATION_H
#define REMOTE_DESKTOP_REGISTRATION_H

#include <iostream>
#include <string>
#include <vector>

class Registration {
  std::string response;

  public:
  Registration(const std::vector<std::string>& data_user);
  std::string get_response() { return response; };
};


#endif

#pragma once

#include <optional>
#include <string>

class Storage {
    static std::optional<std::string> save(char data, int line);
    static std::optional<std::string> load(const int line);
};
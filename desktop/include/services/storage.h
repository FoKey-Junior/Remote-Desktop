#pragma once

#include <optional>
#include <string>

class Storage {
public:
    static std::optional<std::string> save(const std::string& data, int line);
    static std::optional<std::string> load(const int line);
};
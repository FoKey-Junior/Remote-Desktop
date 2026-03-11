#ifndef REMOTE_DESKTOP_STRING_UTILS_H
#define REMOTE_DESKTOP_STRING_UTILS_H

#include <optional>
#include <string>
#include <regex>

const std::regex pattern_email(R"((\w+)(\.\w+)*@(\w+)(\.\w+)+)");
[[nodiscard]] std::optional<std::string> length_check(const std::string& string_data, std::size_t min, std::size_t max);
[[nodiscard]] std::optional<std::string> email_check(const std::string& string_data);

#endif

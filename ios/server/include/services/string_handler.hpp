#pragma once

#include <optional>
#include <string>

[[nodiscard]] std::optional<std::string> length_check(const std::string& string_data, std::size_t min, std::size_t max);
[[nodiscard]] std::optional<std::string> email_check(const std::string& string_data);
#include <optional>
#include <string>
#include <format>
#include <regex>
#include <string_view>
#include "../include/StringUtils.hpp"

std::optional<std::string> length_check(const std::string& string_data, std::size_t min, std::size_t max) {
    if (string_data.size() < min) {
        return std::format("Поле ввода должно содержать не менее {} символов", min);
    } else if (string_data.size() > max) {
        return std::format("Поле ввода не должно превышать {} символов", max);
    }

    return std::nullopt;
}

std::optional<std::string> email_check(const std::string& string_data) {
    if (!std::regex_match(string_data, pattern_email)) {
        return "Введите в поле ввода действительный адрес электронной почты";
    }

    return std::nullopt;
}

#include "services/StringHandler.hpp"
#include <regex>

static const std::regex pattern_email(
    R"((\w+)(\.\w+)*@(\w+)(\.\w+)+)",
    std::regex::optimize
);

std::optional<std::string> length_check(const std::string& string_data, std::size_t min, std::size_t max) {
    if (string_data.size() < min) {
        return "Поле ввода должно содержать не менее " + std::to_string(min) + " символов";
    }

    if (string_data.size() > max) {
        return "Поле ввода не должно превышать " + std::to_string(max) + " символов";
    }

    return std::nullopt;
}

std::optional<std::string> email_check(const std::string& string_data) {
    if (!std::regex_match(string_data, pattern_email)) {
        return "Введите в поле ввода действительный адрес электронной почты";
    }

    return std::nullopt;
}
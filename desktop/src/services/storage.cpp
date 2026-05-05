#include <fstream>
#include <vector>
#include <string>
#include <optional>
#include "services/storage.h"

std::optional<std::string> Storage::save(char data, const int line) {
    std::vector<std::string> lines_contents;
    std::ifstream file_contents("data.bin");

    if (file_contents.is_open()) {
        std::string current_line;
        while (std::getline(file_contents, current_line)) {
            lines_contents.push_back(current_line);
        }
        file_contents.close();
    }

    while (lines_contents.size() <= line) {
        lines_contents.push_back("");
    }

    lines_contents[line] = std::string(1, data);

    std::ofstream outgoing_file("data.bin");
    if (outgoing_file.is_open()) {
        for (const auto& l : lines_contents) {
            outgoing_file << l << "\n";
        }
        outgoing_file.close();

        return lines_contents[line];
    }

    return std::nullopt;
}

std::optional<std::string> Storage::load(const int line) {
    std::ifstream file_contents("data.bin");

    if (file_contents.is_open()) {
        std::vector<std::string> lines_contents;
        std::string current_line;

        while (std::getline(file_contents, current_line)) {
            lines_contents.push_back(current_line);
        }
        file_contents.close();

        if (line >= 0 && line < lines_contents.size()) {
            return lines_contents[line];
        }
    }

    return std::nullopt;
}
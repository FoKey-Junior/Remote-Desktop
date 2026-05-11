#include <QCoreApplication>
#include <QStandardPaths>

#include <fstream>
#include <vector>
#include <string>
#include <optional>

#include "services/storage.h"

Storage::Storage() {
    QCoreApplication::setOrganizationName(company_name);
    QCoreApplication::setApplicationName(program_name);

    QString system_storage_directory = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);

    storage_directory.setPath(system_storage_directory);

    if (!storage_directory.exists()) {
        storage_directory.mkpath(".");
    }
}

std::optional<std::string> Storage::save(const std::string& data, const int line) const {
    std::vector<std::string> lines_contents;
    std::string path = storage_directory.filePath("data.bin").toStdString();
    std::ifstream file_contents(path);

    if (file_contents.is_open()) {
        std::string current_line;
        while (std::getline(file_contents, current_line)) {
            lines_contents.push_back(current_line);
        }
        file_contents.close();
    }

    while (lines_contents.size() <= static_cast<size_t>(line)) {
        lines_contents.push_back("");
    }

    lines_contents[line] = data;

    std::ofstream outgoing_file(path);
    if (outgoing_file.is_open()) {
        for (const auto& l : lines_contents) {
            outgoing_file << l << "\n";
        }
        outgoing_file.close();

        return lines_contents[line];
    }

    return std::nullopt;
}

std::optional<std::string> Storage::load(const int line) const {
    std::string path = storage_directory.filePath("data.bin").toStdString();
    std::ifstream file_contents(path);

    if (file_contents.is_open()) {
        std::vector<std::string> lines_contents;
        std::string current_line;

        while (std::getline(file_contents, current_line)) {
            lines_contents.push_back(current_line);
        }
        file_contents.close();

        if (line >= 0 && line < static_cast<int>(lines_contents.size())) {
            return lines_contents[line];
        }
    }

    return std::nullopt;
}
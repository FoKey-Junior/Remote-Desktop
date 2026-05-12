#pragma once

#include <QDir>

#include <optional>
#include <string>

class Storage {
    QString company_name = "FoKey Junior";
    QString program_name = "Remote Desktop";
    QDir storage_directory;
public:
    Storage();
    [[nodiscard]] std::optional<std::string> save(const std::string& data, int line) const;
    [[nodiscard]] std::optional<std::string> load(const int line) const;
};
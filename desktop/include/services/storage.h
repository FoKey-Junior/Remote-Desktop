#pragma once

#include <QDir>

#include <optional>
#include <string>

class Storage {
private:
    QString company_name = "FoKey Junior";
    QString program_name = "Remote Desktop";
    QDir storage_directory;
public:
    Storage();
    std::optional<std::string> save(const std::string& data, int line) const;
    std::optional<std::string> load(const int line) const;
};
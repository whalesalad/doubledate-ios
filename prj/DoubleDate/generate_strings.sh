./backup_file.sh en.lproj/Localizable.strings
./backup_file.sh sv.lproj/Localizable.strings
./backup_file.sh ru.lproj/Localizable.strings

find . -name \*.m | xargs genstrings -o en.lproj
find . -name \*.m | xargs genstrings -o sv.lproj
find . -name \*.m | xargs genstrings -o ru.lproj
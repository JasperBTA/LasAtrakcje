#!/bin/bash

# Zabezpieczenie przed błędem
set -e

# Znajdź obecną wersję
CURRENT_VERSION=$(grep -oP '(?<=^version: )[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+' pubspec.yaml)

if [ -z "$CURRENT_VERSION" ]; then
    echo "Nie można znaleźć wersji w pubspec.yaml!"
    exit 1
fi

echo "Obecna wersja: $CURRENT_VERSION"

# Wyciągnij numery (x.y.z+b)
MAJOR=$(echo $CURRENT_VERSION | cut -d. -f1)
MINOR=$(echo $CURRENT_VERSION | cut -d. -f2)
PATCH=$(echo $CURRENT_VERSION | cut -d. -f3 | cut -d+ -f1)
BUILD=$(echo $CURRENT_VERSION | cut -d+ -f2)

# Podbij Patch i Build
NEW_PATCH=$((PATCH + 1))
NEW_BUILD=$((BUILD + 1))
NEW_VERSION="$MAJOR.$MINOR.$NEW_PATCH+$NEW_BUILD"

echo "Podbijam wersję do: $NEW_VERSION"

# Podmień w pubspec.yaml (kompatybilne z systemami Linux/Mac/GitBash)
sed -i "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml

echo "Wersja podbita! Uruchamiam /d/Las/.shorebird/bin/shorebird release android..."
/d/Las/.shorebird/bin/shorebird release android


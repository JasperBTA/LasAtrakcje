#!/bin/bash

# Zabezpieczenie przed błędem
set -e

echo "Rozpoczynam generowanie łatki OTA (Patch)..."
echo "Ta komenda wyśle bezprzewodową aktualizację dla wersji widocznej obecnie w pubspec.yaml."
echo ""

# Uruchomienie łatki
/d/Las/.shorebird/bin/shorebird patch android

echo ""
echo "✅ Gotowe! Jeśli wszystko poszło dobrze, łatka poleciała w chmurę."

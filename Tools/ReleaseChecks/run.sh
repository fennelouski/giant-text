#!/bin/sh
set -eu
cd "$(dirname "$0")/../.."
checks_dir=$(mktemp -d)
trap 'rm -rf "$checks_dir"' EXIT
xcrun swiftc -parse-as-library -o "$checks_dir/checks" \
  'Giant Text/Item.swift' 'Giant Text/ColorTheme.swift' \
  'Giant Text/TextAnimation.swift' 'Giant Text/ContentViewState.swift' \
  'Giant Text/UserDefaults+AppGroup.swift' 'Giant Text/ContentViewActions.swift' \
  Tools/ReleaseChecks/main.swift
"$checks_dir/checks"

#!/bin/sh
APPDIR="/usr/share/mechanix/mechanix-calculator"
exec "$APPDIR/mechanix_calculator" --bundle="$APPDIR" "$@"

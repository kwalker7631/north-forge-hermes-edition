#!/usr/bin/env bash
cd "$(dirname "$0")"

echo "Current mode file:"
if [ -f ".forge-mode" ]; then cat ".forge-mode"; else echo "(none set - defaults to SALES)"; fi
echo ""
read -p "Type FULL or SALES and press Enter: " MODE

case "$(echo "$MODE" | tr '[:upper:]' '[:lower:]')" in
    full)
        echo "full" > ".forge-mode"
        echo "Set to FULL. Run launch-north-forge.sh to rebuild this drive's live skills/context with everything."
        ;;
    sales)
        echo "sales" > ".forge-mode"
        echo "Set to SALES. Run launch-north-forge.sh to rebuild this drive's live skills/context with Sales Assist only."
        ;;
    *)
        echo "Didn't recognize that - type exactly FULL or SALES."
        ;;
esac

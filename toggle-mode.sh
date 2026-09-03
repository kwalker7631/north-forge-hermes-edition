#!/usr/bin/env bash
cd "$(dirname "$0")"

while true; do
    echo ""
    echo "Current mode file:"
    if [ -f ".forge-mode" ]; then cat ".forge-mode"; else echo "(none set - defaults to SALES)"; fi
    echo ""
    read -p "Type FULL, SALES, RESET, EXIT, or Q (blank = quit): " MODE

    case "$(echo "$MODE" | tr '[:upper:]' '[:lower:]')" in
        ""|exit|quit|q)
            break
            ;;
        full)
            echo "full" > ".forge-mode"
            echo "Set to FULL. Run launch-north-forge.sh to rebuild this drive's live skills/context with everything."
            ;;
        sales)
            echo "sales" > ".forge-mode"
            echo "Set to SALES. Run launch-north-forge.sh to rebuild this drive's live skills/context with Sales Assist only."
            ;;
        reset)
            echo ""
            echo "RESET wipes this drive's PERSONAL setup back to a clean first-use state:"
            echo "  .env           - your Anthropic API key"
            echo "  .forge-mode    - the FULL/SALES toggle"
            echo "  .hermes.md     - generated at launch, rebuilds automatically"
            echo "  .hermes/skills/ - generated at launch, rebuilds automatically"
            echo ""
            echo "The tracked repo content is NOT touched - skills-source/, mode-blocks/, the scripts."
            echo "Use this before handing this physical drive to a different person, so your"
            echo "API key does not travel with it and the next person gets a genuine first run."
            echo ""
            read -p "Type YES (all caps) to confirm: " CONFIRM
            if [ "$CONFIRM" = "YES" ]; then
                rm -f ".env" ".forge-mode" ".hermes.md"
                rm -rf ".hermes/skills"
                echo ""
                echo "Done. This drive is back to a clean first-use state."
                echo "Next person: run launch-north-forge.sh - it recreates .env from .env.example"
                echo "and prompts for their own API key. Mode defaults to SALES until toggle-mode sets it."
            else
                echo ""
                echo "Cancelled - nothing was deleted."
            fi
            ;;
        *)
            echo "Didn't recognize that - type exactly FULL, SALES, RESET, or EXIT."
            ;;
    esac
done

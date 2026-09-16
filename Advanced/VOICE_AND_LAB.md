# Voice, names, and the imagination lab

## Press-to-speak (Hermes, not us)

Official: https://hermes-agent.nousresearch.com/docs/guides/use-voice-mode-with-hermes

In the **CLI / TUI** (`hermes` then `/voice on`):

| Key | Role |
|---|---|
| **Ctrl+B** | Default record. Speak. Silence stops the take. |
| **Ctrl+Space** | Alternate if Ctrl+B fights the terminal or tmux. Set `voice.record_key: "ctrl+space"` |

Hands-free-ish: leave `/voice on`; after each reply the loop can start again. Tune `silence_threshold` / `silence_duration` if it cuts you off. `/voice tts` speaks the answer (Edge TTS is the free default).

**Desktop app:** Ctrl+B may toggle the sidebar instead of the mic. Use the on-screen mic, or stay in Terminal. That is an upstream quirk, not our theme.

This is dictation into the **desk**, not Pinokio.

## Named agents

Hermes profiles / bots. Landing name is North Forge (SOUL.md). A person may rename the profile in the dashboard. "Hermes Epic" would be another profile or a model alias — not a second product. Weather / time / traffic are tool calls (`web` / device time) on that same session. Do not invent a wake-word stack this week.

## Imagination lab (optional, other disk)

Unlimited Docker images and HF / Civitai checkpoints are a **zoo**. Pinokio Discover + Docker backend can reach them. Hugging Face and Civitai stay in *their* UIs or a Pinokio script. We do not vendor those catalogs into the Kyocera pack or onto exFAT fleet sticks.

Inspire on a lab PC. Ship tickets on GREGW-NOREX.

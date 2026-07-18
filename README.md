# Mitra v0.7

Your personal AI assistant — ask anything, online or fully offline.

## What's new in v0.7
- Brighter, livelier app icon (violet → sky-blue gradient)
- Fixed side drawer: tapping "Assistant" now reliably returns to the home chat from any screen; cleaner drawer UI
- AI Models expanded to 10 curated offline models, grouped by size tier:
  - Tiny (< 1 GB): Gemma 3 1B, Llama 3.2 1B, SmolLM2 1.7B, Qwen 2.5 0.5B
  - Small (1–2 GB): Qwen 2.5 1.5B, Gemma 2 2B, Llama 3.2 3B
  - Capable (2 GB+): Phi-3.5 Mini, Gemma 3 4B, Qwen 2.5 3B
- News: swipe any card left or right to mark it read; the list updates live with a "X left" counter and an "all caught up" state

## Engines
- Groq (online): fast, smartest. Needs internet + free key from console.groq.com/keys
- On-device (offline): private, no internet. Download a model in AI Models first.

Note: the on-device download + inference engine is wired in an upcoming update;
the full offline UI/flow is present now. Online (Groq) chat works today.

## Configure after install
Drawer → Settings → paste Groq key → Save. Or drawer → AI Models → pick & download an offline model.

# Mitra v0.6

Your personal AI assistant — ask anything, online or fully offline.

## What's new in v0.6
- Pivoted from "task manager" to a pure AI assistant
- Hybrid engine: Groq (online) OR on-device model (offline) — user picks in Settings, switch anytime
- New "AI Models" screen: download curated offline models (Gemma 3 1B/4B, Qwen 2.5 1.5B), pick which is active, advanced custom-URL box for power users
- Engine chip on chat screen shows which AI is active
- Gemini removed (Groq is the online option)
- Philosophy expanded: 8 schools (added Taoism, Confucianism, Absurdism), a Thinkers tab with 10 philosophers, and 32 quotes
- Tasks/reminders retired from the main flow (code kept for a future "advanced" module)

## Engines
- **Groq (online):** fast, smartest answers. Needs internet + free API key from console.groq.com/keys
- **On-device (offline):** private, no internet. Download a model first in AI Models.

Note: on-device inference UI + download flow is in this build; the actual local
inference engine is wired in the next update. Online (Groq) chat works now.

## Configure after install
Drawer → Settings → paste Groq key → Save. Or drawer → AI Models → download an offline model.

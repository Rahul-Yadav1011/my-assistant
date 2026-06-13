# Get Your APK — Simple Steps

No Flutter, no Java, no Android SDK on your laptop. Push code to GitHub, GitHub builds the APK, you download it.

Total time: about 20 minutes the first time.

---

## Before you start

- [ ] Install **GitHub Desktop** (~150 MB) from https://desktop.github.com
- [ ] Have your **GitHub account** ready (you said you have one)

---

## Step 1 — Unzip the project

Unzip `my_assistant.zip` to any folder, e.g. `C:\Users\YOU\Documents\my_assistant`.

## Step 2 — Create a GitHub repository

1. Go to https://github.com/new
2. **Repository name:** `my-assistant`
3. **Public**
4. Do NOT add README, .gitignore, or license
5. Click **Create repository**
6. Leave the page open

## Step 3 — Push the project

In GitHub Desktop:

1. **File → Add Local Repository** → browse to your unzipped folder → Select
2. Click **Create a repository** when it says "this isn't a git repository"
3. Click **Create repository** in the dialog
4. Bottom-left: type `first commit` in the Summary box → click **Commit to main**
5. Top: click **Publish repository**
   - Name: `my-assistant`
   - **Uncheck** "Keep this code private"
   - Click **Publish repository**

## Step 4 — Wait for the build

1. Go to `https://github.com/YOUR_USERNAME/my-assistant/actions`
2. You'll see "Build APK" running. Click it to watch progress.
3. Wait until it shows a green checkmark. Takes about 6-8 minutes.

If it fails: click the failing step, copy the error, send it to me.

## Step 5 — Download the APK

1. On the green workflow page, scroll to the bottom
2. Under **Artifacts**, click `app-release-apk` to download a zip
3. Open the zip → inside is `app-release.apk`

## Step 6 — Install on your phone

Get the APK to your phone any way you like:
- Google Drive (upload from laptop, download on phone), OR
- Email it to yourself and open attachment on phone, OR
- USB cable copy, OR
- WhatsApp "saved messages" to yourself

On your phone, tap the APK file. Android will say:
> "For your security, your phone is not allowed to install unknown apps from this source"

Tap **Settings** → enable the toggle → press back → **Install**.

## Step 7 — Configure

1. Open the app, grant microphone and notification permissions
2. Tap the gear icon (top-right) → Settings
3. Paste your free Gemini API key from https://aistudio.google.com/apikey
4. (Optional) Paste your Groq key from https://console.groq.com/keys
5. Save

Try it: tap the mic button and say *"remind me to drink water in 5 minutes"*.

---

## Making changes later

Edit any file on your laptop → open GitHub Desktop → Commit → Push → wait 8 min → download new APK.

That's the entire ongoing workflow.

---

## If something breaks

- **Build fails in GitHub Actions** → click the red X, expand the failing step, paste the error message
- **APK installs but crashes** → most common cause is the Gemini key is wrong or empty. Open settings and re-paste.
- **Voice doesn't work** → Settings → Apps → My Assistant → Permissions → Microphone must be enabled
- **Reminders don't fire** → Settings → Apps → My Assistant → Notifications must be on. Also: Settings → Apps → Special access → Alarms & reminders → My Assistant must be allowed.

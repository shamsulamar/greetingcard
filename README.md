# Greeting Card

A Flutter web demo hosted on GitHub Pages. Visitors write a greeting, enter their email and the recipient email, then send it. EmailJS delivers the mail with a link to accept the card.

Live site: https://shamsulamar.github.io/greetingcard/

Today's send count and public note wall: https://shamsulamar.github.io/greetingcard/#/stats

The old URL `https://shamsulamar.github.io/greatingcard/` redirects here so existing QR codes and email links still work.

The wall shows greeting **text only**. Sender and recipient emails stay private. Stats reads `notes.json`. A GitHub Action appends a new note to that file after someone sends a greeting.

To let the live site queue a note (the write token never has to live in git):

1. Create a fine-grained personal access token with access only to this repository and **Actions: Read and write**.
2. Add it as the repository secret `NOTE_DISPATCH_TOKEN`.
3. Redeploy from `main` so the GitHub Action build can pass that secret into the web app.

The Action uses `GITHUB_TOKEN` to commit `notes.json`. That commit token is not in the website source.

## Local demo

```bash
flutter pub get
flutter run -d chrome
```

Email is sent only after EmailJS is configured.

## EmailJS setup

1. Create a free account at [https://www.emailjs.com](https://www.emailjs.com).
2. Add an **Email Service** (Gmail is fine for a demo). Copy the **Service ID** (looks like `service_xxxxxxx`).
3. Add an **Email Template** with:
   - **To email:** `{{recipient_email}}`
   - **Reply To:** `{{sender_email}}`
   - **Subject:** `A greeting for you`
   - **Content:**

     ```
     {{sender_email}} sent you a greeting:

     {{message}}

     Open and accept it here:
     {{card_url}}
     ```

4. Copy the **Template ID** (`template_xxxxxxx`).
5. Open **Account → General** and copy the **Public Key**.
6. Under **Account → Security**, allow origin `https://shamsulamar.github.io`.
7. Put the three values into `lib/emailjs_config.dart` `defaultValue:` fields, or pass them at build time:

```bash
flutter build web --release --base-href /greetingcard/ \
  --dart-define=EMAILJS_SERVICE_ID=service_xxxxxxx \
  --dart-define=EMAILJS_TEMPLATE_ID=template_xxxxxxx \
  --dart-define=EMAILJS_PUBLIC_KEY=your_public_key
```

Until those values are set, **Send greeting** still works but does not mail anything.

# Greeting Card

A Flutter web demo: write a greeting, enter sender and recipient emails, then share a card link. The recipient opens the link and taps **Accept greeting**.

This demo is hosted on **GitHub Pages**. There is no backend, so email is not actually sent. The greeting is encoded in the share link.

## Local demo

```bash
flutter pub get
flutter run -d chrome
```

## GitHub Pages

The repository name must be `greatingcard` so the deploy workflow’s `--base-href /greatingcard/` matches.

1. Create a GitHub repository named `greatingcard`.
2. Push this project to the `main` branch.
3. In the repo: **Settings → Pages → Build and deployment → Source: GitHub Actions**.
4. After the **Deploy to GitHub Pages** workflow succeeds, the site is at:

`https://<your-github-username>.github.io/greatingcard/`

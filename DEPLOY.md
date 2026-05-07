# Deployment — Vercel

Both apps are hosted on Vercel (free):
- **Next.js** → Vercel project (auto-deploy via GitHub integration)
- **Flutter Web** → separate Vercel static project (auto-deploy via GitHub Actions)

---

## Step 1 — Deploy Flutter Web to Vercel

Flutter can't be built on Vercel directly, so GitHub Actions builds it and pushes the static output to a separate Vercel project.

### a) Create the Flutter Vercel project
1. Go to https://vercel.com → **Add New Project**
2. Don't import a repo — choose **Deploy a template** or just skip to the CLI method:

```bash
# Install Vercel CLI
npm i -g vercel

# From inside flutter-app/
cd flutter-app
flutter build web --release
cd build/web
vercel deploy --prod
```

3. When asked, create a **new project** (e.g. `coinpilot-flutter`)
4. After deploy, note the URL: `https://coinpilot-flutter.vercel.app`

### b) Get the project IDs for GitHub Actions
```bash
# Inside flutter-app/build/web after running vercel deploy once:
cat .vercel/project.json
# shows: { "orgId": "xxx", "projectId": "yyy" }
```

### c) Add GitHub secrets
Go to GitHub repo → **Settings → Secrets → Actions** → add:

| Secret | Value |
|--------|-------|
| `VERCEL_FLUTTER_TOKEN` | Vercel API token (vercel.com → Settings → Tokens) |
| `VERCEL_ORG_ID` | `orgId` from project.json |
| `VERCEL_FLUTTER_PROJECT_ID` | `projectId` from project.json |

From now on, every push to `main` auto-builds Flutter and deploys to Vercel.

---

## Step 2 — Deploy Next.js to Vercel

1. Go to https://vercel.com → **Add New Project**
2. Import `krishna-fortmindz/COINPILOT` from GitHub
3. Set **Root Directory** to `nextjs-app`
4. Framework preset: **Next.js** (auto-detected)
5. Add environment variables:

| Variable | Value |
|----------|-------|
| `NEXT_PUBLIC_FLUTTER_DASHBOARD_URL` | `https://coinpilot-flutter.vercel.app/dashboard` |
| `FLUTTER_APP_URL` | `https://coinpilot-flutter.vercel.app` |

6. Click **Deploy**

Every push to `main` auto-deploys Next.js via Vercel's GitHub integration.

---

## Result

| | URL |
|-|-----|
| Landing / Auth / Blog | `https://coinpilot.vercel.app` |
| Dashboard | `https://coinpilot-flutter.vercel.app/dashboard` |

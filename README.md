# nahweeezy.com

Personal site of [@Nahweeezy](https://youtube.com/@Nahweeezy). Currently a placeholder landing page — portfolio, about-me, and links to other work will land here.

## Stack

Vite (no React) for the dev server + production build. Static HTML/CSS/JS otherwise. Single-page for now.

```
/
├── index.html               # landing
├── style.css                # site styles (Inter / Bebas Neue / Oswald / Space Grotesk)
├── script.js                # currently unused — entry placeholder
├── src/landing/main.js      # imports CSS, wires smooth-scroll on anchor links
├── public/assets/           # fonts, icons, legal — copied verbatim into /dist
├── package.json
├── vite.config.js
├── tailwind.config.js
├── postcss.config.js
├── vercel.json              # framework: vite, build: npm run build, output: dist
└── .env.example             # VITE_GA_MEASUREMENT_ID
```

## Local development

```bash
npm install
npm run dev
# → http://localhost:5173
```

To enable Google Analytics, copy `.env.example` to `.env` and fill in your `VITE_GA_MEASUREMENT_ID`. Without it, the GA tracking script will load with a literal placeholder ID and do nothing harmful (no measurement, no errors).

## Deploy

Push to `main` and Vercel auto-detects the Vite preset. Set `VITE_GA_MEASUREMENT_ID` under **Settings → Environment Variables** if you want analytics on production.

## Roadmap

- About-me content
- Portfolio / projects section (links out to https://github.com/nahweeezy/Pluck etc.)
- Newsletter / contact form

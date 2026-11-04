# Changelog

## v1.0.0

- `deploy.yml`: production guard, build and deploy to Vercel, Netlify or Cloudflare Workers, and the deploy markers.
- `guard.yml`, `mark.yml`: the guard and the markers on their own, for a repository that keeps its own deploy step.
- `bootstrap.yml`: seeds `deploy/{env}/current` once per environment.
- Caller templates for each host in `templates/`.

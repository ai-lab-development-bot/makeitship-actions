# Changelog

## v1.0.2

- The production guard also admits `makeitship-release-early[bot]`, the bot of MakeItShip's early-access App, beside `makeitship-release[bot]`.

## v1.0.1

- Vercel: the token reaches the CLI only through the `VERCEL_TOKEN` environment variable, never on the command line, as Vercel's CLI docs recommend.
- Vercel template `rollback.yml` passes `vercel_staging_alias`, so rolling staging back also moves its stable address. Copy the line into an existing caller to get it.
- Vercel template `deploy-production.yml` no longer lists a placeholder it does not use.
- README: the host's secrets go into the repository's secrets, never into an environment (GitHub Free ignores environment secrets on a private repository).

## v1.0.0

- `deploy.yml`: production guard, build and deploy to Vercel, Netlify or Cloudflare Workers, and the deploy markers.
- `guard.yml`, `mark.yml`: the guard and the markers on their own, for a repository that keeps its own deploy step.
- `bootstrap.yml`: seeds `deploy/{env}/current` once per environment.
- Caller templates for each host in `templates/`.

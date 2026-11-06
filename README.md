# MakeItShip deploy workflows

Shared, versioned GitHub Actions workflows that deploy a site connected to [MakeItShip](https://makeitship.com). A repository keeps a few short caller files; the deploy, the production guard and the deploy markers live here. When a fix lands in a major version, every repository that calls it gets the fix.

Hosts: **Vercel**, **Netlify**, **Cloudflare Workers**.

## How it fits together

| In your repository (`.github/workflows/`) | Calls | What happens |
|---|---|---|
| `deploy-staging.yml` | `deploy.yml@v1` | Every push to `staging` deploys the staging site and records it |
| `deploy-production.yml` | `deploy.yml@v1` | MakeItShip's **Publish** starts it at a `vX.Y.Z` tag. Production deploys, and the deploy is recorded |
| `rollback.yml` | `deploy.yml@v1` | MakeItShip's **Roll back** starts it to redeploy the previous version |
| `bootstrap-markers.yml` | `bootstrap.yml@v1` | Run once per environment so Roll back knows what is live |

`deploy.yml` runs three jobs:

- **guard**: production only. The run stops unless MakeItShip (the `makeitship-release` GitHub App) or a login in the repository variable `PRODUCTION_DEPLOYERS` started it. A production deploy started from MakeItShip must also run on a `vX.Y.Z` tag.
- **deploy**: builds the site and deploys it to the host.
- **mark**: writes the deploy markers MakeItShip reads (`deploy/{env}/{timestamp}` and the moving `deploy/{env}/current`). They give MakeItShip the live version and Roll back.

A repository that needs its own deploy step keeps it and calls `guard.yml` before the deploy and `mark.yml` after it. Publish and Roll back then behave the same.

## Set up a repository

1. Copy the four files from `templates/<host>/` into `.github/workflows/` and replace the `__PLACEHOLDERS__`. An optional value you do not use, such as the Vercel staging domain, becomes an empty string `""`.
2. Add the host's secrets. Put them in the repository's `production` and `staging` environments where your GitHub plan allows it, otherwise in the repository secrets:

   | Host | Secrets | Values in the caller files |
   |---|---|---|
   | Vercel | `VERCEL_TOKEN` | `vercel_org_id`, `vercel_project_id`; optionally `vercel_staging_alias` |
   | Netlify | `NETLIFY_AUTH_TOKEN` | `netlify_site_id`, `output_dir` |
   | Cloudflare | `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID` | the Worker name; each environment deploys `<name>-staging` or `<name>-production` |

3. Optional: set the repository variable `PRODUCTION_DEPLOYERS` to the GitHub logins, comma-separated, of the people who may deploy production by hand.
4. Turn off the host's own Git deploys for production, so production changes only through these workflows. The host can keep building previews.
5. Merge the callers, then run **Bootstrap Deploy Markers** once for `staging` and once for `production`.

Settings the callers rely on: each calling job grants `contents: write` (the markers are git tags), and each environment has its own concurrency group (`deploy-staging`, `deploy-production`). The templates already carry both.

## Build options

`node_version` (default `20`), `node_cache` (default `npm`; set `pnpm`, `yarn`, or `""` to turn caching off), `install_command` (default `npm ci`), `build_command` (default `npm run build`). Vercel builds with the project's own settings.

## Versions

Releases are tagged `vX.Y.Z`, and the major tag (`v1`) moves to the latest release in that line. Callers use `@v1`. A breaking change ships as `v2`, and a repository moves to it with a pull request when it is ready.

Adding, renaming or removing a caller file, or changing a caller's trigger or inputs, is a breaking change: it ships as a new major, never inside `v1`. MakeItShip checks the caller files and brings them to the production branch during setup, so it supports a new major before that major is tagged.

## What MakeItShip depends on

Do not change these in a caller file. Publish and Roll back fail without them, and the failure is easy to miss:

- **The caller files and their paths.** MakeItShip reads `.github/workflows/deploy-production.yml`, `deploy-staging.yml` and `rollback.yml` on both the staging and the production branch. During setup it brings exactly these three files to the production branch, through a pull request you merge. `bootstrap-markers.yml` is run once by hand and is not checked.
- **No push trigger in production.** `deploy-production.yml` runs only on `workflow_dispatch`, with the inputs `tag` and `triggered_by`.
- **The rollback inputs.** `rollback.yml` declares `target_environment`, `target_ref`, `backup_key` and `row_id`, and has `change ${{ inputs.row_id }}` in its `run-name`.
- **The environment word in the workflow name.** It contains `Staging`, `Production` or `Rollback`.
- **The markers.** They are annotated tags whose message is `deployedSHA=`, `parentSHA=` and `backupKey=`.

## Development

`./scripts/check.sh` runs actionlint over the workflows and over every host's templates, and checks that the marker step is identical in `deploy.yml` and `mark.yml`. CI runs the same script.

## License

[MIT](LICENSE)

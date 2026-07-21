# bun-buildpack

Custom [Cloud Native Buildpack](https://buildpacks.io) builder that bundles the [kilterset/heroku-bun-buildpack](https://github.com/kilterset/heroku-bun-buildpack) on Paketo's Jammy full stack. Designed to deploy [Bun](https://bun.sh) applications via `pack` or [Epinio](https://epinio.io).

## Repository

- **GitHub**: <https://github.com/michaelruelas/bun-buildpack>
- **Image**: `ghcr.io/michaelruelas/cnb-builder-bun:v1.0.0`

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [pack CLI](https://buildpacks.io/docs/tools/pack/) (v0.32+)
- [Epinio](https://docs.epinio.io/) CLI (if deploying to an Epinio cluster)
- Access to a container registry (this docs uses `codeberg.org`)

## Quickstart

### 1. Build the builder image

```bash
pack builder create \
  ghcr.io/michaelruelas/cnb-builder-bun:v1.0.0 \
  --config builder.toml
```

If building for `linux/arm64` from an `amd64` machine (e.g., CI on x86 targeting Apple Silicon or ARM cluster nodes):

```bash
pack builder create \
  ghcr.io/michaelruelas/cnb-builder-bun:v1.0.0 \
  --config builder.toml \
  --publish
```

The `--publish` flag builds and pushes directly to the registry, avoiding cross-platform `docker load` issues.

### 2. Push to registry

If you built locally without `--publish`:

```bash
docker push ghcr.io/michaelruelas/cnb-builder-bun:v1.0.0
```

### 3. Deploy an app with Epinio

```bash
epinio push \
  --name my-app \
  --path /path/to/app \
  --builder-image ghcr.io/michaelruelas/cnb-builder-bun:v1.0.0
```

> For Epinio's staging pod to pull the builder image, the registry must be accessible from the cluster. If the registry requires authentication, configure an `imagePullSecret` in the Epinio namespace or set registry credentials under `image.builder` in the [Epinio Helm chart](https://docs.epinio.io/).

### 4. Verify

```bash
epinio app show my-app
```

Check that the staging pod used the custom builder image and the app starts successfully.

## Makefile targets

| Target   | Description                                        |
| -------- | -------------------------------------------------- |
| `build`  | Build the builder image locally                    |
| `publish`| Cross-platform build and push directly to registry |
| `push`   | Push a locally-built image to the registry         |

```bash
make build
make publish   # builds + pushes (arm64 from amd64)
make push      # push existing local image
```

## About the buildpacks

### kilterset/bun (hardened)

- **Source**: `./buildpack/` in this repo
- **Upstream**: <https://github.com/kilterset/heroku-bun-buildpack>
- Detects Bun projects and installs the Bun runtime during build.

**Hardening applied in this fork:**

| Issue | Upstream | Fork |
|-------|----------|------|
| Install method | `curl https://bun.sh/install \| bash` (unpinned) | GitHub Releases download with SHA-256 verification |
| Version pinning | Install script unpinned | Fully checksummed — every download verified |
| Default version | Latest release (non-deterministic) | `1.0.0` (configurable via `BUN_VERSION` or `.bun-version`) |
| Architecture | `arm64` only | `amd64` + `arm64` |

### paketo-buildpacks/procfile

- **Source**: <https://github.com/paketo-buildpacks/procfile>
- Official Paketo buildpack that launches processes defined in a `Procfile`.
- Included as a fallback order group for apps that use a `Procfile` instead of bun auto-detection.

## Repositories

| Repo | URL |
|------|-----|
| Builder config | <https://github.com/michaelruelas/bun-buildpack> |
| Hardened buildpack | <https://github.com/michaelruelas/heroku-bun-buildpack> |

## Local development

Clone both repos as siblings:

```bash
git clone https://github.com/michaelruelas/bun-buildpack.git
git clone https://github.com/michaelruelas/heroku-bun-buildpack.git \
  bun-buildpack/../heroku-bun-buildpack

cd bun-buildpack
make build
```

`builder.toml` references the buildpack as `uri = "../heroku-bun-buildpack"` — works out of the box when both repos are cloned side by side.

## License

MIT

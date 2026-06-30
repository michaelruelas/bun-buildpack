# bun-buildpack

Custom [Cloud Native Buildpack](https://buildpacks.io) builder that bundles the [kilterset/heroku-bun-buildpack](https://github.com/kilterset/heroku-bun-buildpack) on Paketo's Jammy full stack. Designed to deploy [Bun](https://bun.sh) applications via `pack` or [Epinio](https://epinio.io).

## Repository

- **Codeberg**: <https://codeberg.org/michaelruelas/bun-buildpack>
- **Image**: `forgejo.qubitquilt.dev/qubitquilt/cnb-builder-bun:v0.1.0`

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [pack CLI](https://buildpacks.io/docs/tools/pack/) (v0.32+)
- [Epinio](https://docs.epinio.io/) CLI (if deploying to an Epinio cluster)
- Access to a container registry (this docs uses `forgejo.qubitquilt.dev`)

## Quickstart

### 1. Build the builder image

```bash
pack builder create \
  forgejo.qubitquilt.dev/qubitquilt/cnb-builder-bun:v0.1.0 \
  --config builder.toml
```

If building for `linux/arm64` from an `amd64` machine (e.g., CI on x86 targeting Apple Silicon or ARM cluster nodes):

```bash
pack builder create \
  forgejo.qubitquilt.dev/qubitquilt/cnb-builder-bun:v0.1.0 \
  --config builder.toml \
  --publish
```

The `--publish` flag builds and pushes directly to the registry, avoiding cross-platform `docker load` issues.

### 2. Push to registry

If you built locally without `--publish`:

```bash
docker login forgejo.qubitquilt.dev
docker push forgejo.qubitquilt.dev/qubitquilt/cnb-builder-bun:v0.1.0
```

### 3. Deploy an app with Epinio

```bash
epinio push \
  --name my-app \
  --path /path/to/app \
  --builder-image forgejo.qubitquilt.dev/qubitquilt/cnb-builder-bun:v0.1.0
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

### kilterset/bun

- **Source**: <https://github.com/kilterset/heroku-bun-buildpack>
- Detects Bun projects and installs the Bun runtime during build.
- **⚠️ Caveats**:

  - The `bin/build` script runs `curl https://bun.sh/install | bash` — an unpinned curl-pipe-bash pattern. The `BUN_VERSION` env var from `project.toml` only filters available releases; it does not pin the install script itself.
  - The buildpack currently declares `[[targets]] os = "linux" arch = "arm64"` only. If your cluster or CI runs on `amd64`, either:
    - Fork the repo and remove or broaden the `[[targets]]` block
    - Use `--platform linux/arm64` with `pack` if your CI supports QEMU emulation
  - The upstream repo has limited activity. Consider forking and hardening before production use.

### paketo-buildpacks/procfile

- **Source**: <https://github.com/paketo-buildpacks/procfile>
- Official Paketo buildpack that launches processes defined in a `Procfile`.
- Included as a fallback order group for apps that use a `Procfile` instead of bun auto-detection.

## Adding a forked / hardened bun buildpack

If you fork the kilterset buildpack to pin versions or broaden architecture support, update `builder.toml`:

```toml
[[buildpacks]]
  id = "kilterset/bun"
  uri = "https://github.com/YOUR_USER/heroku-bun-buildpack"
  version = "1.0.0"
```

Or use a local path during development:

```toml
[[buildpacks]]
  id = "kilterset/bun"
  uri = "../heroku-bun-buildpack"
  version = "1.0.0"
```

## Local development

```bash
# Clone the buildpack repo for iteration
git clone https://github.com/kilterset/heroku-bun-buildpack.git

# Point builder.toml at the local clone
# Then rebuild the builder
make build
```

## License

MIT

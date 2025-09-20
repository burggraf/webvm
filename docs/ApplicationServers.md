# Application Server Runtimes

WebVM can boot from custom EXT2 disk images generated from Dockerfiles. This page
documents the application-focused runtimes that we curate for the "Application
Servers" gallery as well as the work needed to build additional images.

## Static HTTP Server (reference implementation)

* **Dockerfile:** [`dockerfiles/static-http/Dockerfile`](../dockerfiles/static-http/Dockerfile)
* **Runtime goal:** serve `/home/user/www` over BusyBox `httpd` on port 8080.
* **EXT2 build:** select `dockerfiles/static-http/Dockerfile` when triggering the
  `Deploy` GitHub Action. The workflow exports the container root filesystem to
  an EXT2 disk and updates the `config_github_terminal.js` file automatically.
* **Usage:** the runtime drops into an HTTP server session immediately. You can
  replace `default.html` or extend the Dockerfile to copy a full site before
  building the image.

This minimal runtime is a good template for "drop a single binary, run it" use
cases. The Supabase Edge Functions runtime described below builds on the same
workflow but requires extra tooling.

## Node.js runtime

* **Dockerfile:** [`dockerfiles/node-runtime/Dockerfile`](../dockerfiles/node-runtime/Dockerfile)
* **Runtime goal:** ship a ready-to-edit Node.js project that listens on port
  8080 and boots straight into the sample `server.js` HTTP service.
* **Node version:** Node.js 18.19.1 (latest 32-bit LTS release – newer major
  versions no longer provide official `linux/386` builds).
* **EXT2 build:** select `dockerfiles/node-runtime/Dockerfile` when triggering
  the `Deploy` GitHub Action. A 256 MiB disk image leaves enough room for
  `npm install` plus small projects without wasting space.
* **Usage:** the runtime starts `/usr/local/bin/start-node.sh`, which drops you
  into `/home/user/app`. Replace `server.js` or initialize a full project as
  needed; the helper script only re-creates the sample server when the file is
  missing.

## Supabase Edge Functions runtime (experimental)

Supabase Edge Functions are executed by Deno; therefore a complete runtime needs
three layers:

1. the Supabase CLI to manage projects and invoke functions,
2. the Deno runtime that actually executes the TypeScript handlers, and
3. supporting toolchains (git, build-essential, etc.) so developers can tweak
   the project from inside WebVM.

### Release support status

* Supabase currently ships Linux binaries for `amd64` and `arm64` only. The
  v2.40.7 release assets include packages such as
  `supabase_2.40.7_linux_amd64.deb`, `supabase_2.40.7_linux_amd64.tar.gz`, and
  `supabase_2.40.7_linux_arm64.deb`—there is no `linux_386` variant yet.
* The Deno project also distributes `x86_64` and `aarch64` builds exclusively.
  The latest release publishes archives like `deno-x86_64-unknown-linux-gnu.zip`
  and `deno-aarch64-unknown-linux-gnu.zip`, but nothing for 32-bit x86.

Because WebVM images are exported as 32-bit EXT2 disks, we cannot bundle a
working Deno binary today. The Dockerfile nevertheless lays the groundwork so we
can drop the executables in as soon as upstream adds 32-bit support or we manage
an in-house port.

### Dockerfile overview

* **Location:** [`dockerfiles/supabase-edge-functions/Dockerfile`](../dockerfiles/supabase-edge-functions/Dockerfile)
* **Build process:** a multi-stage build compiles the Supabase CLI from source
  for `linux/386`. The builder runs on the host architecture via BuildKit (so it
  can use the official `golang:1.24` image) and then copies the resulting binary
  into the 32-bit runtime layer. If the compilation fails, the image will still
  build but a placeholder wrapper is installed instead.
* **Runtime contents:**
  - `/home/user/project/functions/hello/index.ts` – a sample edge function you
    can edit immediately.
  - `/opt/supabase/cli-src` – the Supabase CLI repository to help with manual
    rebuilds or patching.
  - `/opt/supabase/README.txt` – explains the remaining blockers and directs
    maintainers to the relevant resources.
  - `/usr/local/bin/start-supabase-edge.sh` – startup script that surfaces the
    research summary and drops you into an interactive shell.

### Building an EXT2 image

1. Commit any changes you want in the Dockerfile or templates.
2. Trigger the **Deploy** workflow with the following parameters:
   - `DOCKERFILE_PATH = dockerfiles/supabase-edge-functions/Dockerfile`
   - Pick an image size large enough to host your functions (512 MiB is plenty).
   - Enable `DEPLOY_TO_GITHUB_PAGES` if you want the build hosted automatically.
3. Download the resulting EXT2 chunks from the workflow artifact (or the GitHub
   release if you toggled that option) and point your configuration file at the
   generated `.ext2` image.

Even though the workflow emits an EXT2 image, the startup script will currently
warn about the missing Deno binary. You can still use the environment to edit
functions, inspect the Supabase CLI source tree, or experiment with cross-
compiling the CLI for `linux/386`.

### Next steps once 32-bit builds are available

When upstream provides compatible binaries, update the runtime as follows:

1. Drop the Deno release tarball into the runtime during the Docker build and
   add it to the `PATH`.
2. Remove the placeholder wrapper in `/usr/local/bin/supabase` so the compiled
   CLI is invoked directly.
3. Extend `start-supabase-edge.sh` to call `supabase functions serve --env-file`
   (or the desired entry point) once the runtime can actually execute edge
   functions.

Until then the runtime remains in "research" mode, but it gives us a reproducible
build context and documentation trail for future work.

# syntax=docker/dockerfile:1.6

# Build the Supabase CLI from source for linux/386 when possible.
FROM --platform=$BUILDPLATFORM golang:1.24 AS supabase-builder
ARG SUPABASE_VERSION=v2.40.7
WORKDIR /src
RUN git clone --depth 1 --branch ${SUPABASE_VERSION} https://github.com/supabase/cli.git .
RUN --mount=type=cache,target=/go/pkg/mod \
        bash -c 'set -euo pipefail; mkdir -p /out; :> /out/supabase; \
        set +e; GOOS=linux GOARCH=386 CGO_ENABLED=0 go build -o /out/supabase ./; status=$?; \
        set -e; echo $status > /out/build.exitcode; cp -a . /out/cli-src'

# Final runtime image built for i386 to match WebVM expectations.
FROM --platform=i386 i386/debian:bookworm
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        unzip \
        build-essential \
        pkg-config \
        libssl-dev \
        zlib1g-dev \
        python3 \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Provide a regular user, mirroring the other runtimes.
RUN useradd -m user && echo "user:password" | chpasswd

# Bring over the compiled CLI (if available) and the upstream source tree.
COPY --from=supabase-builder /out/supabase /opt/supabase/bin/supabase
COPY --from=supabase-builder /out/build.exitcode /opt/supabase/bin/build.exitcode
COPY --from=supabase-builder /out/cli-src /opt/supabase/cli-src

# Runtime bootstrap files.
COPY dockerfiles/supabase-edge-functions/edge-function.ts /opt/supabase/templates/hello/index.ts
COPY dockerfiles/supabase-edge-functions/start-supabase-edge.sh /usr/local/bin/start-supabase-edge.sh

RUN set -eux; \
    chmod +x /usr/local/bin/start-supabase-edge.sh; \
    mkdir -p /home/user/project/functions/hello; \
    cp /opt/supabase/templates/hello/index.ts /home/user/project/functions/hello/index.ts; \
    status="$(cat /opt/supabase/bin/build.exitcode)"; \
    rm /opt/supabase/bin/build.exitcode; \
    if [ "$status" -eq 0 ]; then \
        install -m 0755 /opt/supabase/bin/supabase /usr/local/bin/supabase; \
    else \
        printf '#!/bin/sh\n' > /usr/local/bin/supabase; \
        printf 'echo "Supabase CLI binary for linux/386 is not bundled. Review /opt/supabase/README.txt for next steps."\n' >> /usr/local/bin/supabase; \
        chmod +x /usr/local/bin/supabase; \
    fi; \
    printf '%s\n' \
      'Supabase Edge Functions rely on the Deno runtime.' \
      'Deno releases only provide x86_64 and aarch64 builds, so serving functions in this 32-bit image is currently blocked.' \
      'The Supabase CLI source tree is mirrored in /opt/supabase/cli-src for experimentation with cross-compilation.' \
      > /opt/supabase/README.txt; \
    chown -R user:user /home/user /opt/supabase

USER user
WORKDIR /home/user/project
ENV HOME=/home/user TERM=xterm

CMD ["/usr/local/bin/start-supabase-edge.sh"]

# syntax=docker/dockerfile:1.4
FROM --platform=linux/386 debian:bookworm-slim AS runtime

ARG NODE_VERSION=18.19.1
ARG NODE_DISTRO=linux-x86

# Install Node.js and create the runtime user.
RUN useradd -m user \
    && mkdir -p /home/user/app /opt/node \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl xz-utils \
    && curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-${NODE_DISTRO}.tar.xz" \
      | tar -xJ --strip-components=1 -C /opt/node \
    && apt-get purge -y --auto-remove curl xz-utils \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/node/bin:${PATH}" \
    NODE_ENV=production

# Provide a starter application and launch script.
COPY ./dockerfiles/node-runtime/server.js /home/user/app/server.js
COPY ./dockerfiles/node-runtime/start-node.sh /usr/local/bin/start-node.sh
RUN chown -R user:user /home/user \
    && chmod +x /usr/local/bin/start-node.sh

USER user
WORKDIR /home/user/app
ENV HOME=/home/user TERM=xterm

CMD ["/usr/local/bin/start-node.sh"]

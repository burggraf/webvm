# syntax=docker/dockerfile:1.4
FROM --platform=linux/386 debian:bookworm-slim AS runtime

ARG NODE_VERSION=18.19.1
ARG NODE_DISTRO=linux-x86
ARG NEXT_APP_DIR=/home/user/next-app

# Install Node.js and set up the runtime user.
RUN useradd -m user \
    && mkdir -p ${NEXT_APP_DIR} /opt/node /usr/local/bin \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl xz-utils \
    && curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-${NODE_DISTRO}.tar.xz" \
      | tar -xJ --strip-components=1 -C /opt/node \
    && apt-get purge -y --auto-remove curl xz-utils \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/node/bin:${PATH}" \
    NODE_ENV=development \
    NEXT_TELEMETRY_DISABLED=1

# Provide the starter Next.js project and launcher script.
COPY ./dockerfiles/next-runtime/start-next.sh /usr/local/bin/start-next.sh
COPY ./dockerfiles/next-runtime/next-app/ ${NEXT_APP_DIR}/

RUN chown -R user:user /home/user \
    && chmod +x /usr/local/bin/start-next.sh

USER user
WORKDIR ${NEXT_APP_DIR}
ENV HOME=/home/user TERM=xterm

RUN npm install --no-audit --no-fund --omit=optional \
    && npm cache clean --force

CMD ["/usr/local/bin/start-next.sh"]

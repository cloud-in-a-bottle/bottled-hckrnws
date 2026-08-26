FROM docker.io/library/node:24-alpine@sha256:d32cdf619f63fe0471182d08996dd516c6275bb5fd31ae06e55a570bd9e1ad43 AS builder

RUN apk add --no-cache git

WORKDIR /src
RUN HCKRNWS_COMMIT=7b71e87c23be2f0608a48ff916d9f2767e092c36 \
    && git init \
    && git remote add origin https://github.com/rajatkulkarni95/hckrnws.git \
    && git fetch --depth 1 origin "$HCKRNWS_COMMIT" \
    && git checkout --detach FETCH_HEAD \
    && test "$(git rev-parse HEAD)" = "$HCKRNWS_COMMIT"

RUN npm ci --include=dev \
    && npm run build

FROM docker.io/nginxinc/nginx-unprivileged:1.31.4-alpine@sha256:901e944d1f4fc2bd077e8f5568b98c1f6f8cdacf6b97a87747c43134a339b9a7

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder --chown=101:101 /src/build/client/ /usr/share/nginx/html/
COPY --from=builder /src/LICENSE.md /usr/share/licenses/hckrnws/upstream-LICENSE.md
COPY LICENSE NOTICE /usr/share/licenses/hckrnws/

EXPOSE 8080

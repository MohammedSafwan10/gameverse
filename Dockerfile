FROM node:24-alpine AS build
WORKDIR /source
COPY website ./website
COPY docs/PRIVACY_POLICY.md ./docs/PRIVACY_POLICY.md
RUN node website/build.mjs

FROM nginx:1.30.5-alpine
COPY website/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /source/website/dist /usr/share/nginx/html
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 CMD wget -q -O /dev/null http://127.0.0.1:8080/health || exit 1

FROM node:22-alpine AS dependencies
WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev

FROM node:22-alpine AS checks
WORKDIR /app
COPY --from=dependencies /app/node_modules ./node_modules
COPY package.json server.mjs schema.sql http_security.mjs http_security.test.mjs ./
RUN node --check server.mjs && node --test http_security.test.mjs \
    && printf 'passed' > /app/.checks-passed

FROM node:22-alpine
WORKDIR /app
COPY --from=dependencies /app/node_modules ./node_modules
COPY package.json server.mjs schema.sql http_security.mjs ./
COPY --from=checks /app/.checks-passed ./.checks-passed
ENV NODE_ENV=production
EXPOSE 8080
USER node
CMD ["node", "server.mjs"]

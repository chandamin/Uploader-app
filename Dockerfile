FROM node:22-slim
# Debian (glibc) instead of Alpine: Rollup's native parser fails on musl with
# "Code is nested too deeply". Prisma needs openssl.
RUN apt-get update -y && apt-get install -y --no-install-recommends openssl && rm -rf /var/lib/apt/lists/*

EXPOSE 3000

WORKDIR /app

ENV NODE_ENV=production

COPY package.json package-lock.json* ./

RUN npm ci --omit=dev && npm cache clean --force

COPY . .

# Generate the Prisma client at build time so startup only runs migrations.
RUN npx prisma generate && npm run build

CMD ["npm", "run", "docker-start"]

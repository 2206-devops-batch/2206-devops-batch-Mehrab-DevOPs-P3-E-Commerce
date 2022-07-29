FROM node:18-bullseye-slim AS builder
WORKDIR /usr/src/app
ENV PATH /usr/src/app/node_modules/.bin:$PATH
COPY ./frontend /usr/src/app
RUN npm ci && npm run build

# production environment
FROM nginx:1.23.1-alpine AS web
COPY --from=builder /usr/src/app/build /usr/share/nginx/html/
EXPOSE 80

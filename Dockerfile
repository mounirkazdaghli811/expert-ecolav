FROM node:22-bookworm-slim
WORKDIR /app
COPY package.json server.mjs backup.mjs ./
COPY public ./public
RUN mkdir -p /data && chown node:node /data
USER node
ENV HOST=0.0.0.0 PORT=3000 DATA_DIR=/data
EXPOSE 3000
CMD ["node","server.mjs"]

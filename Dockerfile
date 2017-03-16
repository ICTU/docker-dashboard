FROM node:4-slim

ENV PORT 80

WORKDIR /app

ADD /bundle /app

RUN cd /app/programs/server && npm i --production

EXPOSE 80

CMD ["node", "main.js"]

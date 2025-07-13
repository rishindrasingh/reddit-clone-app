FROM node:19-alpine3.15

WORKDIR /reddit-clone

COPY . /reddit-clone

RUN npm install --legacy-peer-deps

EXPOSE 3000

CMD ["npm", "run", "dev"]

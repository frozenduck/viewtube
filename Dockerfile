FROM node:13

RUN curl -o- -L https://yarnpkg.com/install.sh | bash
RUN useradd --user-group --create-home --shell /bin/false app

ENV PATH=/root/.yarn/bin:$PATH
ENV HOME=/home/app/

COPY package.json yarn.lock $HOME
RUN chown -R app $HOME/*

USER app
WORKDIR $HOME
RUN yarn install
RUN yarn build

USER root
COPY . $HOME
RUN chown -R app $HOME/*

EXPOSE 8066

ENV NUXT_HOST=0.0.0.0
ENV NUXT_PORT=8066

USER app
CMD ["npm", "start"]
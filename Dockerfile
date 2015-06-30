FROM ubuntu:14.04

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

### Set environment variables ###
ENV appDir /var/www/app/current

### Set the work directory
WORKDIR ${appDir}

### / ###

### Run updates and install deps ###

RUN apt-get update

RUN apt-get install -y git ruby wget curl rake gcc nginx make \
libcurl4-openssl-dev ruby-dev libssl-dev \
libcairo2-dev libjpeg8-dev libpango1.0-dev libgif-dev build-essential g++

RUN apt-get -y autoclean

### / ###

### Install NVM ###

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 0.12.5

RUN wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.25.4/install.sh | bash \
    && source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

### / ###

### Make node available ###

RUN ln -s /usr/local/nvm/versions/node/v0.12.5/bin/node /usr/bin/node

### / ###

### Include files from app ###

RUN mkdir -p /var/www/app/current
COPY . /var/www/app/current

### / ###

### Install everything ###
RUN /usr/local/nvm/versions/node/v0.12.5/bin/npm i
### / ###

### restart NGINX ###
RUN service nginx restart

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/v$NODE_VERSION/bin:$PATH
### / ###

### Expose port ###
EXPOSE 4500
### / ###

### App start command ###
CMD ["/usr/local/nvm/versions/node/v0.12.5/bin/pm2", "start", "/var/www/app/current/processes.json", "--no-daemon"]

### Fin ###

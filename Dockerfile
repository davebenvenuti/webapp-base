FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev libpq5 libpq-dev python-pip git-core build-essential curl git software-properties-common gnupg ca-certificates apt-transport-https

# Java
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

RUN apt install -y oracle-java8-installer

RUN pip install nodeenv
RUN nodeenv -n 8.11.3 /node
RUN /bin/bash -c ". /node/bin/activate"

ENV RBENV_ROOT /rbenv
RUN git clone https://github.com/rbenv/rbenv.git /rbenv

RUN echo ". /node/bin/activate" > /etc/profile.d/node.sh
ENV NODE_PATH "/node/lib/node_modules"

ENV PATH "/node/lib/node_modules/.bin:/node/bin:/rbenv/bin:/rbenv/shims:/node/$PATH"

RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh

RUN eval "$(rbenv init -)"
RUN mkdir -p "$(rbenv root)"/plugins
RUN git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

RUN rbenv install 2.4.1
RUN rbenv global 2.4.1
RUN rbenv rehash

RUN gem install bundler

# Fix puma build
# See: https://github.com/puma/puma/issues/1136
RUN apt install -y libssl1.0 libssl1.0-dev
RUN bundle config build.puma --with-cppflags=-I/usr/include/openssl-1.0 --with-ldflags=-L/usr/lib/openssl-1.0

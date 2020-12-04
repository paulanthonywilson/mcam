FROM debian:latest

RUN apt-get update -qq && \
  apt-get upgrade -qq -y && \
  apt-get install -qq -y \
  apt-utils 

RUN apt-get install -qq -y \
  build-essential \
  autoconf \
  libncurses5-dev \
  libssh-dev \
  unixodbc-dev \
  git \
  curl \
  unzip \
  inotify-tools  

RUN apt-get install -qq -y libssl-dev
RUN apt-get install -qq -y procps wget

RUN apt-get clean -qq -y && \
  apt-get autoclean -qq -y && \
  apt-get autoremove -qq -y && \
  rm -rf /var/cache/debconf/*-old && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /usr/share/doc/*

RUN wget https://deb.nodesource.com/setup_10.x 
RUN chmod u+x setup_10.x
RUN ./setup_10.x 
RUN apt-get install -y nodejs


ENV LANG C.UTF-8

# RUN useradd -ms $(which bash) asdf
ARG USER_ID
ARG GROUP_ID

# RUN addgroup --gid $GROUP_ID asdf
RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID asdf
USER asdf

ENV PATH /home/asdf/.asdf/bin:/home/asdf/.asdf/shims:$PATH




# asdf, erlang

RUN /bin/bash -c "git clone https://github.com/asdf-vm/asdf.git ~/.asdf"

RUN /bin/bash -c "asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git" 

RUN /bin/bash -c "asdf install erlang 23.1.1 && \
  asdf global erlang 23.1.1 && \
  rm -rf  /tmp/*"

# elixir

RUN /bin/bash -c "asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git"

RUN /bin/bash -c "asdf install elixir 1.11.2-otp-23 && \
  asdf global elixir 1.11.2-otp-23 && \
  rm -rf  /tmp/*"

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /home/asdf/build


COPY --chown=asdf:dialout . .

USER root
RUN chown asdf:dialout .
USER asdf


CMD ["/bin/bash"]
FROM ruby:3.1.2

RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
    build-essential \
    gnupg2 \
    less \
    git \
    libpq-dev \
    postgresql-client \
    libvips42 \
    apt-utils \
    redis-tools \
    golang-go \
    nodejs \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Erlang, Elixir and Hex
ENV PATH="$PATH:/usr/local/elixir/bin"

RUN wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb && dpkg -i erlang-solutions_2.0_all.deb
RUN apt-get update && apt-get install -yq elixir

ARG PYTHON_VERSION=3.10.5

ENV LANG=en_US.UTF-8 \
    PYENV_ROOT="$HOME/.pyenv" \
    PATH="$HOME/.pyenv/bin:$HOME/.pyenv/shims:$PATH"

# install pyenv & python
RUN curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash \
 && pyenv install ${PYTHON_VERSION} \
 && pyenv global ${PYTHON_VERSION} \
 && pip install --upgrade pip

# RUN python3 -m pip install hashin pipfile poetry

RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
RUN echo 'eval "$(pyenv init -)"' >> ~/.bash_profile

ENV DEPENDABOT_NATIVE_HELPERS_PATH="/opt"

COPY dependabot/ /opt
RUN bash /opt/bundler/helpers/v2/build
RUN bash /opt/go_modules/helpers/build
RUN bash /opt/python/helpers/build

ENV MIX_HOME="/opt/hex/mix"
RUN bash /opt/hex/helpers/build

ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3

WORKDIR /usr/src/app
  
RUN gem update --system && gem install bundler -v 2.3.13

COPY Gemfile Gemfile.lock ./

RUN bundle config build.nokogiri --use-system-libraries

RUN bundle check || bundle install

COPY . ./

ENTRYPOINT ["./entrypoint.sh"]

EXPOSE 3000

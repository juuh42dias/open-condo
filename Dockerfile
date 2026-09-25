# syntax=docker/dockerfile:1
# Production Dockerfile for OpenCondo (Rails 7.2 + Sprockets + importmap).
# No Node.js needed: JS ships via import maps, CSS via sassc-rails (native gem).

ARG RUBY_VERSION=3.4.10
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Production env defaults
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    RAILS_SERVE_STATIC_FILES="true" \
    RAILS_LOG_TO_STDOUT="true"

# Throw-away build stage to reduce final image size
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY . .

# config/database.yml is gitignored (and absent from the build context);
# fall back to the sample — all credentials resolve from ENV at runtime.
RUN if [ ! -f config/database.yml ]; then cp config/database.yml.sample config/database.yml; fi

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompile assets (needs a dummy SECRET_KEY_BASE; real key comes from credentials at runtime)
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final stage
FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libpq5 postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p db log storage tmp && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]

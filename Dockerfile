FROM ruby:3.4 AS builder

RUN mkdir -p /workspace
WORKDIR /workspace

COPY Gemfile Gemfile.lock ./
ENV BUNLDE_WITHOUT=development:test
RUN bundle install

RUN --mount=type=bind,target=/workspace,rw \
    bundle exec jekyll build --destination /var/_site

FROM joseluisq/static-web-server:2 AS runtime

COPY --from=builder /var/_site /var/public
ENTRYPOINT ["/static-web-server", "--root=/var/public", "--health"]

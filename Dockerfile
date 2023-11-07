FROM elixir:alpine

COPY mix.exs /app/mix.exs
COPY mix.lock /app/mix.lock

WORKDIR /app

RUN mix deps.get
RUN mix deps.compile

COPY . /app
RUN mix compile

CMD ["elixir", "--no-halt", "-S", "mix", "start"]

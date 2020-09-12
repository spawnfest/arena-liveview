# ArenaLiveview

To start your Phoenix server you'll need a copy of `.env.example` on `.env` exporting your database connection credentials.

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install` inside the `assets` directory

## Using make

  * Create and migrate your database using the configuration in ready in `.env` with `make setup`
  * Drop your current database to recreate and migrate it with `make reset`
  * Source `.env` file and start a `phx.server` inside an `iex` session with `make server`
  * Run `mix test` by sourcing .env prior to it with `make test`

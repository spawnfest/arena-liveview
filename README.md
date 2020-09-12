# Arena LiveView

LiveView implementation of the [3d-css-scene package](https://www.npmjs.com/package/3d-css-scene). Integrated with Phoenix Sockets and Presence to track and broacast connections and movement in a 3D room.

## Develop

### Dependencies install

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install` inside the `assets` directory

### Setup and run the project

To setup and access your develop database you'll need environment variables with your database server's credentials. You can make a copy of `.env.example` on `.env`.
Following `make` commands will source `.env` file before running their corresponding `mix` tasks.

  * Create and migrate your database using with `make setup`
  * Drop your current database to recreate and migrate it with `make reset`
  * Start a `phx.server` inside an `iex` session with `make server`
  * Run `mix test` with `make test`

Developed by the Spawnfest's [coop team](@spawnfest/coop-team). Go co-ops!

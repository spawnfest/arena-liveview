.PHONY: server setup test

export MIX_ENV ?= dev
export SECRET_KEY_BASE ?= $(shell mix phx.gen.secret)

server: MIX_ENV=dev
server:
	@source .env && iex --name arenaliveview@127.0.0.1 -S mix phx.server

setup: 
	@source .env && mix ecto.setup
reset:
	@source .env && mix ecto.reset

test: MIX_ENV=test
test:
	@source .env && mix test

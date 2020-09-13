# Arena LiveView

## Introduction

This project is a LiveView implementation of the [3d-css-scene package](https://www.npmjs.com/package/3d-css-scene), integrated with Phoenix Sockets and [Presence](https://hexdocs.pm/phoenix/Phoenix.Presence.html) to track and broacast connections and movement in a 3D room.

<p align="center">
  <a href="https://www.youtube.com/watch?v=-FYJf__jmAY" target="_blank">
    <img src="public/demo.gif" width="50%">
  </a>
  <br/>
  <br/>
  <a href="https://pure-journey-52122.herokuapp.com/">
   <strong>Live demo!</strong>
  </a>
</p>

## Implementation

This initial implementation is carried out as part of the [Spawnfest 2020](https://spawnfest.github.io/) hackathon and contains.
This web application allows users to create or join rooms where other people can join and share a synchronized youtube experience together. As part of the 3D scene, roomates are be able to see each other running around while listening.
The user interface is quite simple. It allows users to see and join any of the available public rooms, keep track of how many arenies are gathered together. They also get a temporary unique avatar, all in a fancy elixirish styled overlay.

### Creating a room

Upon visiting the site you can create rooms by providing:

+ `title` a fancy title for the room
+ `slug` a name that generates a unique url for you to share with others
+ `video url` this is an optional youtube url to get the room funkier. Live videos are allowed!
+ `privacy` you can create private rooms by checking this box. This will only affect the public room list, users will be able to join by visiting the `slug` url.

### Current Features

+ Public rooms creation
+ Private rooms creations
+ Dynamic public rooms list, with connected users.
+ Youtube video time synchronization on room join
+ Video time tracking upon leaving room
+ Users movement tracking and rendering
+ Temporary dynamically generated avatars for joiners

### Future features

+ Ability to delete rooms
+ User profile. Ability to assign you own name, social network, ids, status.
+ Movements interpolation
+ General and p2p chats
+ Collision engine integration
+ Collaborative room construction engine
+ Voice chat (web RTC)
+ Avatar color selection
+ Mobile responsiveness
+ Mobile sensors integration

## Quick development start

### Dependencies install

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install` inside the `assets` directory

### Setup and run the project

This project uses `postgresql`. You'll need to configure the environment variables to setup your local database credentials. You should make a copy of `.env.example` on `.env`.

The following `make` commands will source the `.env` file before running their corresponding `mix` tasks.

  * Create and migrate your database using with `make setup`
  * Drop your current database to recreate and migrate it with `make reset`
  * Start a `phx.server` inside an `iex` session with `make server`
  * Run `mix test` with `make test`

---

The avatar generator module comes from [identikoso](https://github.com/casanovajose/identikoso)

Developed by the Spawnfest's [coop team](@spawnfest/coop-team). Go co-ops!

# Athena-Mercure

Proof of concept integration between Athena and Mercure.

## Getting Started

### Setup

1. `docker compose up`
1. `source .env`
1. `crystal src/server.cr`

### Usage

1. Navigate to http://localhost:8080/
1. Open the console, should see `Listening...`
1. Hitup http://localhost:3000/book/1 in another tab or via `curl` or something
1. Should see a message come through in the console.

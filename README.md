# Maintenance Tracker

A web app for tracking vehicle maintenance — intervals, service history, and upcoming service needs. Built with Rails 8.1 and PostgreSQL, deployed on a home Kubernetes cluster.

## Prerequisites

- **Ruby 4.0.1** — managed via [mise](https://mise.jdx.dev/)
- **PostgreSQL** — running locally or via Docker
- **Node.js** is _not_ required (uses Importmap)

## Setup

```sh
# Install mise if you don't have it
brew install mise
eval "$(mise activate zsh)"  # add to your ~/.zshrc

# Install Ruby (mise reads .ruby-version automatically)
mise install

# Install gem dependencies
bundle install

# Start PostgreSQL (if using Docker)
docker run -d --name maintenance-tracker-pg \
  -e POSTGRES_HOST_AUTH_METHOD=trust \
  -p 5432:5432 \
  postgres:17

# Create and migrate the database
bin/rails db:setup
```

## Running the App

```sh
bin/dev                    # Start the dev server (localhost:3000)
```

## Common Commands

```sh
bin/rails server           # Start Puma
bin/rails console          # Interactive Rails console
bin/rails test             # Run tests (Minitest)
bin/rails test:system      # Run system tests
bin/rails generate ...     # Generators (model, scaffold, migration, etc.)
bin/rails db:migrate       # Run pending migrations
bin/rails db:seed          # Seed the database
bin/rails routes           # Show all routes
bundle exec rubocop        # Lint
```

## Tech Stack

- **Framework:** Rails 8.1.2
- **Language:** Ruby 4.0.1
- **Database:** PostgreSQL
- **Front-end:** Hotwire (Turbo + Stimulus) via Importmap
- **Background jobs:** Solid Queue
- **Caching:** Solid Cache
- **WebSockets:** Solid Cable
- **Deployment:** Kamal (targeting k8s cluster)

## Testing

Tests use Minitest (Rails default). Run them with:

```sh
bin/rails test             # Unit + integration tests
bin/rails test:system      # System tests (browser-based)
bin/ci                     # Full CI suite (tests, linting, security audits)
```

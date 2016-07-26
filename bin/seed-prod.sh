export MIX_ENV=prod
set -x

export DATABASE_URL=`heroku config:get DATABASE_URL`
export OLD_DATABASE_URL=`heroku config:get DATABASE_URL --app critter4us`
export POOL_SIZE=3

mix compile
mix ecto.migrate
mix run priv/repo/1-seed-non-users.exs  # --verbosity=verbose
mix run priv/repo/2-seed-secret-users.exs
# Don't want users with github-visible passwords in the database
# mix run priv/repo/3-seed-test-users.exs 

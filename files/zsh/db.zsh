alias db='functions db'

_dbexists() {
  local name="${1//\'/\'\'}"
  psql -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '$name'" | grep -q 1
}

_userexists() {
  local name="${1//\'/\'\'}"
  psql -d postgres -tc "SELECT 1 FROM pg_user WHERE usename = '$name'" | grep -q 1
}

dblist () { # List all PostgreSQL databases # ➜ dblist [filter]
  local result=$(psql -d postgres -tc "SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY oid DESC")
  if [[ -n "$1" ]]; then
    echo "$result" | grep -i "$1"
  else
    local total=$(echo "$result" | wc -l | tr -d ' ')
    echo "$result" | head -20
    (( total > 20 )) && echo "\ntotal \e[34m$total\e[0m"
  fi
}

dbconnect () { # Connect to a database # ➜ dbconnect myapp
  local name="${1:-postgres}"
  psql -d "$name"
}

dbinfo () { # Show info about a database # ➜ dbinfo myapp
  local name="${1:-$(basename "$(pwd)")}"
  _dbexists "$name" || { echo "Database '$name' does not exist. Usage: dbinfo <database_name>"; return 1; }
  local escaped="${name//\'/\'\'}"
  psql -d postgres -c "
    SELECT
      datname as name,
      pg_size_pretty(pg_database_size(datname)) as size,
      pg_catalog.pg_get_userbyid(datdba) as owner,
      pg_catalog.pg_encoding_to_char(encoding) as encoding
    FROM pg_database
    WHERE datname = '$escaped'
  "
}

dbcreate () { # Create database with user, test db, and .env files # ➜ dbcreate
  local name="${1:-$(basename "$(pwd)")}"
  local testname="${name}-test"

  _dbexists "$name" && { echo "Database '$name' already exists"; return 1; }

  local password=$(openssl rand -base64 32 | tr -d '=+/' | head -c 32)

  if ! _userexists "$name"; then
    psql -d postgres -c "CREATE USER \"$name\" WITH PASSWORD '$password' CREATEDB;" || return 1
    echo "Created user: $name"
  else
    psql -d postgres -c "ALTER USER \"$name\" WITH PASSWORD '$password';" || return 1
    echo "Updated password for user: $name"
  fi

  createdb -O "$name" "$name" || return 1
  echo "Created database: $name"

  createdb -O "$name" "$testname" || return 1
  echo "Created database: $testname"

  local url="DATABASE_URL=postgresql://${name}:${password}@localhost:5432/${name}"
  local testurl="DATABASE_URL=postgresql://${name}:${password}@localhost:5432/${testname}"

  if [[ -f .env ]]; then
    grep -q '^DATABASE_URL=' .env && sed -i '' '/^DATABASE_URL=/d' .env
  fi
  echo "$url" >> .env
  echo "Updated .env"

  if [[ -f .env.test ]]; then
    grep -q '^DATABASE_URL=' .env.test && sed -i '' '/^DATABASE_URL=/d' .env.test
  fi
  echo "$testurl" >> .env.test
  echo "Updated .env.test"
}

dbpassword () { # Reset password for database user and update .env files # ➜ dbpassword
  local name="${1:-$(basename "$(pwd)")}"

  _userexists "$name" || { echo "User '$name' does not exist"; return 1; }

  local password=$(openssl rand -base64 32 | tr -d '=+/' | head -c 32)

  psql -d postgres -c "ALTER USER \"$name\" WITH PASSWORD '$password';" || return 1
  echo "Updated password for user: $name"

  local url="DATABASE_URL=postgresql://${name}:${password}@localhost:5432/${name}"
  local testurl="DATABASE_URL=postgresql://${name}:${password}@localhost:5432/${name}-test"

  if [[ -f .env ]]; then
    grep -q '^DATABASE_URL=' .env && sed -i '' '/^DATABASE_URL=/d' .env
  fi
  echo "$url" >> .env
  echo "Updated .env"

  if [[ -f .env.test ]]; then
    grep -q '^DATABASE_URL=' .env.test && sed -i '' '/^DATABASE_URL=/d' .env.test
  fi
  echo "$testurl" >> .env.test
  echo "Updated .env.test"
}

dbdrop () { # Drop a database # ➜ dbdrop myapp
  local name="$1"
  [[ -z "$name" ]] && { echo "Usage: dbdrop <database_name>"; return 1; }
  _dbexists "$name" || { echo "Database '$name' does not exist"; return 1; }
  echo -n "Drop database '$name'? [y/N] "
  read -r confirm
  [[ "$confirm" =~ ^[Yy]$ ]] && {
    dropdb "$name" && echo "Dropped: $name"
  }
}

dbsizes () { # Show all database sizes # ➜ dbsizes
  psql -d postgres -c "SELECT datname, pg_size_pretty(pg_database_size(datname)) as size FROM pg_database WHERE datistemplate = false ORDER BY pg_database_size(datname) DESC"
}

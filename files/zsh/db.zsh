_dbexists() {
  local name="${1//\'/\'\'}"
  psql -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '$name'" | grep -q 1
}

dblist () { # List all PostgreSQL databases # ➜ dblist
  psql -d postgres -tc "SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname"
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

dbcreate () { # Create a database # ➜ dbcreate myapp
  local name="${1:-$(basename "$(pwd)")}"
  _dbexists "$name" && { echo "Database '$name' already exists"; return 1; }
  createdb "$name" && echo "Created: $name"
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

-- SCRIPT: 
-- cat /app/seed.sql | PGPASSWORD=${POSTGRES_PASSWORD} psql -h localhost -U ${POSTGRES_USER} -d ${POSTGRES_DB} -f-

-- authelia 
SELECT 'CREATE DATABASE authelia'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'authelia')\gexec

DO
$do$
BEGIN
   IF EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'authelia') THEN

      RAISE NOTICE 'Role "authelia" already exists. Skipping.';
   ELSE
      CREATE ROLE authelia LOGIN PASSWORD 'authelia';
   END IF;
END
$do$;

\c authelia

GRANT CONNECT ON DATABASE authelia TO authelia; 
GRANT ALL ON SCHEMA public TO authelia;


-- gotify
SELECT 'CREATE DATABASE gotify'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'gotify')\gexec

DO
$do$
BEGIN
   IF EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'gotify') THEN

      RAISE NOTICE 'Role "gotify" already exists. Skipping.';
   ELSE
      CREATE ROLE gotify LOGIN PASSWORD 'gotify';
   END IF;
END
$do$;

\c gotify

GRANT CONNECT ON DATABASE gotify TO gotify; 
GRANT ALL ON SCHEMA public TO gotify;



-- maybe
SELECT 'CREATE DATABASE maybe'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'maybe')\gexec

DO
$do$
BEGIN
   IF EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'maybe') THEN

      RAISE NOTICE 'Role "maybe" already exists. Skipping.';
   ELSE
      CREATE ROLE maybe LOGIN PASSWORD 'maybe';
   END IF;
END
$do$;

\c maybe
GRANT CREATE ON DATABASE maybe TO maybe;
GRANT CONNECT ON DATABASE maybe TO maybe; 
GRANT ALL ON SCHEMA public TO maybe;
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



-- firefly
SELECT 'CREATE DATABASE firefly'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'firefly')\gexec

DO
$do$
BEGIN
   IF EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'firefly') THEN

      RAISE NOTICE 'Role "firefly" already exists. Skipping.';
   ELSE
      CREATE ROLE firefly LOGIN PASSWORD 'firefly';
   END IF;
END
$do$;

\c firefly

GRANT CONNECT ON DATABASE firefly TO firefly; 
GRANT ALL ON SCHEMA public TO firefly;


-- pico
SELECT 'CREATE DATABASE pico'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'pico')\gexec

DO
$do$
BEGIN
   IF EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'pico') THEN

      RAISE NOTICE 'Role "pico" already exists. Skipping.';
   ELSE
      CREATE ROLE pico LOGIN PASSWORD 'pico';
   END IF;
END
$do$;

\c pico

GRANT CONNECT ON DATABASE pico TO pico; 
GRANT ALL ON SCHEMA public TO pico;



-- dikodiko
SELECT 'CREATE DATABASE dikodiko'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'dikodiko')\gexec

DO
$do$
BEGIN
   IF EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'dikodiko') THEN

      RAISE NOTICE 'Role "dikodiko" already exists. Skipping.';
   ELSE
      CREATE ROLE dikodiko LOGIN PASSWORD 'dikodiko';
   END IF;
END
$do$;

\c dikodiko

GRANT CONNECT ON DATABASE dikodiko TO dikodiko; 
GRANT ALL ON SCHEMA public TO dikodiko;
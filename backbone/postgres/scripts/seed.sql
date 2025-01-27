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
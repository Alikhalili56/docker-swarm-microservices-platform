-- Create databases and users for services
CREATE USER {{ dex_db_user }} WITH PASSWORD '{{ vault_dex_db_password }}';
CREATE DATABASE {{ dex_db_name }} OWNER {{ dex_db_user }};

CREATE USER {{ forgejo_db_user }} WITH PASSWORD '{{ vault_forgejo_db_password }}';
CREATE DATABASE {{ forgejo_db_name }} OWNER {{ forgejo_db_user }};

CREATE USER {{ grafana_db_user }} WITH PASSWORD '{{ vault_grafana_db_password }}';
CREATE DATABASE {{ grafana_db_name }} OWNER {{ grafana_db_user }};

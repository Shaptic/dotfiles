alias ll='ls -lAh'

alias run_horizon="STELLAR_CORE_DATABASE_URL='postgres://postgres:mysecretpassword@host.docker.internal:5641/stellar?sslmode=disable' HISTORY_ARCHIVE_URLS='https://history.stellar.org/prd/core-testnet/core_testnet_001' NETWORK_PASSPHRASE='Test SDF Network ; September 2015' STELLAR_CORE_URL='http://host.docker.internal:11626' INGEST=true PER_HOUR_RATE_LIMIT=0 DATABASE_URL='postgres://postgres@host.docker.internal:5432/horizon?sslmode=disable' ./horizon"


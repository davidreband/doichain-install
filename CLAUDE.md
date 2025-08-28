# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker-based infrastructure repository for running Doichain blockchain environments. Doichain is a blockchain for email Double Opt-In validation, built on Bitcoin technology with merge mining capabilities through P2Pool.

## Architecture

The repository provides three main deployment configurations:

### Mining Environment (`docker-compose-mining.yml`)
- **Bitcoin Core Node** (doichain/bitcoind:v0.20.0) - Pruned Bitcoin blockchain on port 8332/8333
- **Doichain Core Node** (doichain/core:dc0.20.1.13) - Main Doichain blockchain node on port 8339
- **P2Pool Mining** (doichain/p2pool:v34.0) - P2P merge mining pool for Bitcoin and Doichain on port 9332

### Email DOI Environment (`docker-compose-email-doi-mainnet.yml` / `docker-compose-email-doi-testnet.yml`)  
- **Nginx** (nginx:1.22.0) - Reverse proxy with SSL termination on ports 80/443
- **Certbot** - Let's Encrypt SSL certificate automation
- **Doichain Core Node** (doichain/core:dc0.20.1.13) - Blockchain node on port 8339
- **Doichain dApp** (doichain/dapp:v0.0.9.117) - Email validation application on port 3000
- **MongoDB** (mongo:3.2) - Database for dApp on port 28017

## Common Development Commands

### Starting Services

```bash
# Mining environment (Bitcoin + Doichain + P2Pool)
./start-mining.sh
# OR manually:
cp docker-compose-mining.yml docker-compose.yml
docker compose up

# Email DOI mainnet environment
./start-email-doi-mainnet.sh
# OR manually:
cp docker-compose-email-doi-mainnet.yml docker-compose.yml
docker compose up -d

# Email DOI testnet environment  
./start-email-doi-testnet.sh
# OR manually:
cp docker-compose-email-doi-testnet.yml docker-compose.yml
docker compose up -d
```

### Managing Services

```bash
# View running containers
docker-compose ps

# View logs for all services
docker-compose logs

# View logs for specific service
docker-compose logs <service-name>

# Connect to container
docker-compose exec <service-name> bash

# Stop services
docker-compose down
# OR
./stop.sh

# Clean up everything (DESTRUCTIVE - removes all data)
./deleteEverything.sh
```

### SSL Certificate Setup

```bash
# Initialize Let's Encrypt certificates (for email DOI environments)
./init-letsencrypt.sh
```

## Configuration

### Environment Variables

Create `.env` file from examples:

For mining:
```bash
cp .env.mining.example .env
```
Key variables:
- `P2POOL_DOICHAIN_DEFAULT_ADDR` - Doichain mining address
- `P2POOL_BITCOIN_DEFAULT_ADDR` - Bitcoin mining address

For email DOI:
```bash
cp .env.email-doi.example .env
```
Key variables:
- `SERVER_NAME` - Public domain name
- `RPC_USER/RPC_PASSWORD` - Doichain RPC credentials
- `DAPP_SMTP_*` - Email server configuration

### Network Configuration

Services use static IP networks:
- Mining: 172.21.0.0/16
- Email DOI: 172.20.0.0/16

## Service-Specific Commands

### Doichain Node Operations

```bash
# Connect to doichain container
docker-compose exec doichain bash

# Inside container - common doichain-cli commands:
doichain-cli help
doichain-cli getblockchaininfo
doichain-cli getpeerinfo
doichain-cli createwallet
doichain-cli getbalance
doichain-cli getnewaddress
doichain-cli listtransactions
```

### P2Pool Mining Monitoring

```bash
# Check p2pool logs
docker compose exec p2pool tail -f /home/p2pool/nohup.out

# Check bitcoin sync status
docker compose exec bitcoin tail -f /home/bitcoin/.bitcoin/debug.log
```

### dApp Access

- Web interface: http://localhost:3000
- API documentation: https://github.com/Doichain/dapp/blob/master/doc/en/json-rpc-api.md

## Branch Information

### main branch
- Stable version using `doichain/core:dc0.20.1.13`
- Production-ready deployments

### doichain-nc29-migration branch
- **TESTING ONLY** - Updated version with NC29 migration
- Uses locally built image from `github.com/davidreband/doichain-core:doichain-nc29-migration`
- Includes Namecoin to Doichain migration updates
- Requires extensive testing before production use

## Testing and Deployment

### NC29 Migration Testing
```bash
# Switch to testing branch
git checkout doichain-nc29-migration

# Deploy to Hetzner for testing
SERVER_HOST=your-server.hetzner.com ./deploy-hetzner.sh

# Monitor testing deployment
SERVER_HOST=your-server.hetzner.com ./test-monitoring.sh
```

### Hetzner Deployment Commands
```bash
# Deploy to Hetzner server
./deploy-hetzner.sh

# Monitor deployment
./test-monitoring.sh
```

Refer to `TESTING-NC29.md` for comprehensive testing procedures.

## Development Notes

- Bitcoin node downloads and syncs pruned blockchain on first run - this takes time
- P2Pool will show connection errors until Bitcoin is fully synced
- Volumes persist data between container restarts
- Use `docker-compose exec <service> bash` to debug container issues
- Check container logs with `docker-compose logs <service>` for troubleshooting
- NC29 migration branch builds from source, which takes 30+ minutes
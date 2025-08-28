# Doichain NC29 Migration - Testing Guide

This document provides comprehensive testing procedures for the Doichain NC29 migration version.

## Overview

The NC29 migration represents a significant update that migrates Doichain from the original Namecoin codebase to a more modern implementation. This version includes:

- Updated name operations adapted for Doichain
- Modernized chainparams and genesis block data
- Enhanced DOI (Decentralized Identifier) operations
- Port standardization to 8339
- Comprehensive refactoring from Namecoin to Doichain

## Pre-Testing Setup

### 1. Environment Preparation

```bash
# Clone the testing branch
git checkout doichain-nc29-migration

# Set up environment variables
cp .env.email-doi.example .env
# Edit .env with your specific configuration
```

### 2. Local Testing

```bash
# Build the new image
docker-compose -f docker-compose-email-doi-testnet.yml build

# Start services
docker-compose -f docker-compose-email-doi-testnet.yml up -d

# Monitor startup
docker-compose -f docker-compose-email-doi-testnet.yml logs -f doichain-testnet
```

### 3. Hetzner Deployment

```bash
# Deploy to Hetzner server
SERVER_HOST=your-server.hetzner.com ./deploy-hetzner.sh

# Monitor deployment
SERVER_HOST=your-server.hetzner.com ./test-monitoring.sh
```

## Testing Procedures

### Phase 1: Basic Functionality Testing

#### 1.1 Node Connectivity
```bash
# Check if node is running
docker-compose exec doichain-testnet doichain-cli getblockchaininfo

# Verify network connections
docker-compose exec doichain-testnet doichain-cli getpeerinfo
```

**Expected Results:**
- Node should connect to testnet peers
- Blockchain should start syncing
- RPC should respond correctly

#### 1.2 Wallet Operations
```bash
# Create a test wallet
docker-compose exec doichain-testnet doichain-cli createwallet "testwallet"

# Generate new address
docker-compose exec doichain-testnet doichain-cli getnewaddress

# Check balance
docker-compose exec doichain-testnet doichain-cli getbalance
```

**Expected Results:**
- Wallet creation should succeed
- Address generation should work
- Balance should be 0 for new wallet

### Phase 2: Name Operations Testing (NC29 Specific)

#### 2.1 Name Registration
```bash
# Test name_new operation
docker-compose exec doichain-testnet doichain-cli name_new "test-domain" "test-value"

# Check pending name operations
docker-compose exec doichain-testnet doichain-cli name_list
```

#### 2.2 DOI Operations
```bash
# Test DOI-specific operations (if available)
docker-compose exec doichain-testnet doichain-cli help | grep -i doi
```

### Phase 3: dApp Integration Testing

#### 3.1 dApp Connectivity
```bash
# Check dApp health endpoint
curl -X GET http://localhost:4000/api/health

# Test MongoDB connection
docker-compose exec mongo mongo --eval "db.stats()"
```

#### 3.2 Email DOI Workflow
Test the complete email double opt-in workflow through the dApp interface.

### Phase 4: Performance and Stability Testing

#### 4.1 Load Testing
```bash
# Run continuous blockchain sync test
./test-monitoring.sh

# Monitor resource usage
docker stats --no-stream
```

#### 4.2 Long-running Stability
- Run the system for 24+ hours
- Monitor memory usage
- Check for any crashes or errors

## Monitoring and Logging

### Key Metrics to Monitor

1. **Blockchain Sync Status**
   - Block height progression
   - Peer connections
   - Sync speed

2. **Resource Usage**
   - CPU utilization
   - Memory consumption
   - Disk I/O
   - Network traffic

3. **Error Rates**
   - RPC errors
   - Connection failures
   - Database errors

### Log Analysis

```bash
# Check doichain logs for errors
docker-compose logs doichain-testnet | grep -i error

# Monitor dApp logs
docker-compose logs dapp | tail -f

# System resource monitoring
./test-monitoring.sh > monitoring-report-$(date +%Y%m%d-%H%M%S).log
```

## Known Issues and Workarounds

### Issue 1: Build Time
- **Problem**: Docker build may take 30+ minutes
- **Workaround**: Use pre-built images when available
- **Solution**: Implement multi-stage builds to reduce build time

### Issue 2: Testnet Connectivity
- **Problem**: Limited testnet peers available
- **Workaround**: Use specific connection nodes
- **Monitoring**: Check peer count regularly

### Issue 3: Memory Usage
- **Problem**: Bitcoin blockchain sync requires significant memory
- **Workaround**: Use pruned mode
- **Monitoring**: Set up memory alerts

## Success Criteria

### Minimum Viable Testing
- [ ] Node starts successfully
- [ ] RPC commands respond correctly
- [ ] Wallet operations work
- [ ] Basic name operations function
- [ ] dApp connects to node
- [ ] No critical errors in logs

### Full Production Readiness
- [ ] 24+ hour stability test passed
- [ ] All name operations thoroughly tested
- [ ] Email DOI workflow fully functional
- [ ] Performance benchmarks met
- [ ] Security audit completed
- [ ] Documentation updated

## Rollback Procedure

If critical issues are found:

```bash
# Switch back to stable version
git checkout main

# Rebuild with stable version
docker-compose -f docker-compose-email-doi-testnet.yml build --no-cache

# Restart services
docker-compose -f docker-compose-email-doi-testnet.yml up -d
```

## Reporting Issues

When reporting issues, include:

1. **Environment Details**
   - Server specifications
   - Docker versions
   - Network configuration

2. **Reproduction Steps**
   - Exact commands used
   - Expected vs actual results
   - Timing of the issue

3. **Logs and Evidence**
   - Relevant log excerpts
   - Screenshots if applicable
   - Performance metrics

4. **Impact Assessment**
   - Severity level
   - User impact
   - Business impact

## Next Steps

After successful testing:

1. **Documentation Update**
   - Update CLAUDE.md with new version
   - Create deployment guides
   - Update API documentation

2. **Production Deployment**
   - Create production-ready Docker images
   - Set up monitoring and alerting
   - Plan maintenance windows

3. **Community Release**
   - Publish release notes
   - Update Docker Hub images
   - Announce to community
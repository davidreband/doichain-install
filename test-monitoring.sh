#!/bin/bash
# Monitoring and testing script for Doichain NC29 Migration

set -e

echo "🔍 Doichain NC29 Migration - Test Monitoring"
echo "============================================="

SERVER_USER=${SERVER_USER:-root}
SERVER_HOST=${SERVER_HOST:-localhost}
DEPLOY_PATH=${DEPLOY_PATH:-/opt/doichain}
DOCKER_COMPOSE_FILE=${DOCKER_COMPOSE_FILE:-docker-compose-email-doi-testnet.yml}

# Function to run commands on remote server (or locally if localhost)
run_command() {
    if [ "$SERVER_HOST" = "localhost" ]; then
        eval "$1"
    else
        ssh $SERVER_USER@$SERVER_HOST "$1"
    fi
}

echo "📊 Checking service status..."
run_command "cd $DEPLOY_PATH && docker-compose -f $DOCKER_COMPOSE_FILE ps"

echo ""
echo "🔍 Checking Doichain node health..."
echo "======================================"

echo "📡 RPC Connection Test:"
run_command "cd $DEPLOY_PATH && docker-compose -f $DOCKER_COMPOSE_FILE exec -T doichain-testnet doichain-cli getblockchaininfo" || echo "❌ RPC connection failed"

echo ""
echo "🌐 Network Connection Test:"
run_command "cd $DEPLOY_PATH && docker-compose -f $DOCKER_COMPOSE_FILE exec -T doichain-testnet doichain-cli getpeerinfo | head -20" || echo "❌ Peer connection failed"

echo ""
echo "💾 Database Status:"
run_command "cd $DEPLOY_PATH && docker-compose -f $DOCKER_COMPOSE_FILE exec -T mongo mongo --eval 'db.stats()'" || echo "❌ MongoDB connection failed"

echo ""
echo "📋 Recent logs (last 50 lines):"
echo "================================="
echo ""
echo "🔍 Doichain logs:"
run_command "cd $DEPLOY_PATH && docker-compose -f $DOCKER_COMPOSE_FILE logs --tail=50 doichain-testnet"

echo ""
echo "🌐 dApp logs:"
run_command "cd $DEPLOY_PATH && docker-compose -f $DOCKER_COMPOSE_FILE logs --tail=20 dapp"

echo ""
echo "📊 Container Resource Usage:"
echo "============================="
run_command "docker stats --no-stream --format 'table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}'"

echo ""
echo "🧪 Test Commands to run manually:"
echo "=================================="
echo "1. Check wallet creation:"
echo "   docker-compose -f $DOCKER_COMPOSE_FILE exec doichain-testnet doichain-cli createwallet test"
echo ""
echo "2. Generate test address:"
echo "   docker-compose -f $DOCKER_COMPOSE_FILE exec doichain-testnet doichain-cli getnewaddress"
echo ""
echo "3. Check testnet balance:"
echo "   docker-compose -f $DOCKER_COMPOSE_FILE exec doichain-testnet doichain-cli getbalance"
echo ""
echo "4. Test name operations (NC29 specific):"
echo "   docker-compose -f $DOCKER_COMPOSE_FILE exec doichain-testnet doichain-cli name_new test-domain"
echo ""
echo "5. dApp API test:"
echo "   curl -X GET http://$SERVER_HOST:4000/api/health"
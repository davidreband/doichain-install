#!/bin/bash
# Deployment script for Hetzner hosting - Doichain NC29 Migration Testing

set -e

echo "🚀 Doichain NC29 Migration - Hetzner Deployment Script"
echo "======================================================"

# Configuration
SERVER_USER=${SERVER_USER:-root}
SERVER_HOST=${SERVER_HOST:-""}
DEPLOY_PATH=${DEPLOY_PATH:-/opt/doichain}
DOCKER_COMPOSE_FILE=${DOCKER_COMPOSE_FILE:-docker-compose-email-doi-testnet.yml}

# Check required variables
if [ -z "$SERVER_HOST" ]; then
    echo "❌ Error: SERVER_HOST environment variable is required"
    echo "Usage: SERVER_HOST=your-server.example.com ./deploy-hetzner.sh"
    exit 1
fi

echo "📋 Deployment Configuration:"
echo "   Server: $SERVER_USER@$SERVER_HOST"
echo "   Deploy Path: $DEPLOY_PATH"
echo "   Docker Compose: $DOCKER_COMPOSE_FILE"
echo ""

# Function to run commands on remote server
run_remote() {
    echo "🔧 Running on server: $1"
    ssh $SERVER_USER@$SERVER_HOST "$1"
}

# Function to copy files to remote server
copy_to_server() {
    echo "📁 Copying: $1 → $SERVER_HOST:$2"
    scp -r "$1" $SERVER_USER@$SERVER_HOST:"$2"
}

echo "🔍 Step 1: Checking server connection..."
if ! ssh -o ConnectTimeout=10 $SERVER_USER@$SERVER_HOST "echo 'Connection successful'"; then
    echo "❌ Cannot connect to server $SERVER_HOST"
    exit 1
fi

echo "📦 Step 2: Installing dependencies on server..."
run_remote "apt-get update && apt-get install -y docker.io docker-compose git"

echo "🐳 Step 3: Starting Docker service..."
run_remote "systemctl enable docker && systemctl start docker"

echo "📂 Step 4: Creating deployment directory..."
run_remote "mkdir -p $DEPLOY_PATH"

echo "📋 Step 5: Copying project files..."
copy_to_server "." "$DEPLOY_PATH/"

echo "🔧 Step 6: Setting up environment..."
run_remote "cd $DEPLOY_PATH && cp .env.email-doi.example .env"

echo "🏗️  Step 7: Building Doichain image (this may take a while)..."
run_remote "cd $DEPLOY_PATH && docker-compose -f $DOCKER_COMPOSE_FILE build doichain-testnet"

echo "🚀 Step 8: Starting services..."
run_remote "cd $DEPLOY_PATH && docker-compose -f $DOCKER_COMPOSE_FILE up -d"

echo "📊 Step 9: Checking service status..."
run_remote "cd $DEPLOY_PATH && docker-compose -f $DOCKER_COMPOSE_FILE ps"

echo ""
echo "✅ Deployment completed successfully!"
echo ""
echo "🔗 Next steps:"
echo "   1. Configure your .env file on the server: ssh $SERVER_USER@$SERVER_HOST 'nano $DEPLOY_PATH/.env'"
echo "   2. Restart services: ssh $SERVER_USER@$SERVER_HOST 'cd $DEPLOY_PATH && docker-compose -f $DOCKER_COMPOSE_FILE restart'"
echo "   3. Check logs: ssh $SERVER_USER@$SERVER_HOST 'cd $DEPLOY_PATH && docker-compose -f $DOCKER_COMPOSE_FILE logs'"
echo ""
echo "🌐 Access points:"
echo "   - Doichain testnet RPC: $SERVER_HOST:18339"
echo "   - dApp interface: $SERVER_HOST:4000"
echo "   - MongoDB: $SERVER_HOST:28017"
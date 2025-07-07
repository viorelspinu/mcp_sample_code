#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if uv is installed
print_info "Checking for uv..."
if ! command -v uv &> /dev/null; then
    print_error "uv is not installed. Please install it first:"
    echo ""
    echo "macOS/Linux:"
    echo "  curl -LsSf https://astral.sh/uv/install.sh | sh"
    echo ""
    echo "Windows:"
    echo "  powershell -ExecutionPolicy ByPass -c \"irm https://astral.sh/uv/install.ps1 | iex\""
    echo ""
    echo "Or visit: https://docs.astral.sh/uv/getting-started/installation/"
    exit 1
fi
print_success "uv is installed"

# Check if ngrok is installed
print_info "Checking for ngrok..."
if ! command -v ngrok &> /dev/null; then
    print_error "ngrok is not installed. Please install it first:"
    echo ""
    echo "macOS (with Homebrew):"
    echo "  brew install ngrok/ngrok/ngrok"
    echo ""
    echo "Linux:"
    echo "  curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null"
    echo "  echo 'deb https://ngrok-agent.s3.amazonaws.com buster main' | sudo tee /etc/apt/sources.list.d/ngrok.list"
    echo "  sudo apt update && sudo apt install ngrok"
    echo ""
    echo "Windows:"
    echo "  Download from: https://ngrok.com/download"
    echo ""
    echo "Or visit: https://ngrok.com/docs/getting-started/"
    exit 1
fi
print_success "ngrok is installed"

# Check if ngrok is authenticated
print_info "Checking ngrok authentication..."
if ! ngrok config check &> /dev/null; then
    print_warning "ngrok is not authenticated"
    echo ""
    echo "🔐 Please get your ngrok auth token:"
    echo "   1. Go to https://dashboard.ngrok.com/get-started/your-authtoken"
    echo "   2. Sign up/login to your ngrok account"
    echo "   3. Copy your auth token"
    echo ""
    read -p "Enter your ngrok auth token: " NGROK_TOKEN
    
    if [ -z "$NGROK_TOKEN" ]; then
        print_error "No auth token provided. Exiting."
        exit 1
    fi
    
    print_info "Setting up ngrok authentication..."
    ngrok config add-authtoken "$NGROK_TOKEN"
    
    if [ $? -eq 0 ]; then
        print_success "ngrok authentication successful"
    else
        print_error "Failed to authenticate ngrok"
        exit 1
    fi
else
    print_success "ngrok is authenticated"
fi

# Set default port
MCP_PORT=${MCP_PORT:-8080}

# Check if AUTH_CODE is set
if [ -z "$AUTH_CODE" ]; then
    print_error "AUTH_CODE environment variable is not set!"
    echo ""
    echo "Please set AUTH_CODE environment variable before running this script:"
    echo "  export AUTH_CODE=your_secret_code"
    echo "  ./start_mcp.sh"
    echo ""
    exit 1
fi

print_info "Starting MCP server setup..."
echo ""
echo "🚀 This script will:"
echo "   1. Start your MCP server on port $MCP_PORT"
echo "   2. Expose it via ngrok tunnel"
echo "   3. Provide you with a public URL for Claude.ai"
echo ""

# Start the MCP server in the background
print_info "Starting MCP server on port $MCP_PORT..."
uv run python sample_server.py &
MCP_PID=$!

# Wait a moment for the server to start
sleep 3

# Check if the server is running
if ! kill -0 $MCP_PID 2>/dev/null; then
    print_error "Failed to start MCP server"
    exit 1
fi
print_success "MCP server started (PID: $MCP_PID)"

# Start ngrok tunnel
print_info "Starting ngrok tunnel..."
ngrok http $MCP_PORT --log=stdout &
NGROK_PID=$!

# Wait for ngrok to start and get the public URL
sleep 5

# Get the public URL from ngrok API
PUBLIC_URL=$(curl -s http://localhost:4040/api/tunnels | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data['tunnels'][0]['public_url'])
except:
    print('')
")

if [ -z "$PUBLIC_URL" ]; then
    print_error "Failed to get ngrok public URL"
    print_info "Cleaning up..."
    kill $MCP_PID $NGROK_PID 2>/dev/null
    exit 1
fi

print_success "Server is now publicly accessible!"
echo ""
echo "🌐 Server URL with Auth: ${PUBLIC_URL}?code=${AUTH_CODE}"
echo ""
echo "📋 To add this to Claude.ai:"
echo "   1. Go to https://claude.ai/settings/integrations"
echo "   2. Add MCP server with URL: ${PUBLIC_URL}?code=${AUTH_CODE}"
echo ""
echo "🔧 Server is running..."
echo "   - MCP Server PID: $MCP_PID"
echo "   - ngrok PID: $NGROK_PID"
echo "   - Press Ctrl+C to stop both services"
echo ""

# Function to cleanup on exit
cleanup() {
    echo ""
    print_info "Shutting down services..."
    kill $MCP_PID $NGROK_PID 2>/dev/null
    print_success "Services stopped"
    exit 0
}

# Set up trap for cleanup
trap cleanup SIGINT SIGTERM

# Keep the script running
print_info "Services running. Press Ctrl+C to stop."
wait
# MCP Sample Server

A comprehensive Model Context Protocol (MCP) server implementation with FastMCP, featuring authentication, network switch log simulation, and automated ngrok tunnel setup for easy integration with Claude.ai.

## Features

- **🚀 FastMCP Server**: Built with FastMCP for high-performance MCP protocol support
- **🔐 Authentication**: Secure auth code validation for all API endpoints
- **📊 Network Simulation**: Realistic network switch log generation
- **🌐 Ngrok Integration**: Automated tunnel setup with wizard-like configuration
- **⚡ Modern Python**: Built with Python 3.10+ and uv package management
- **🔧 Easy Setup**: One-script deployment with comprehensive error handling

## Quick Start

### Prerequisites

- Python 3.10+
- uv package manager
- ngrok account (for public access)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/viorelspinu/mcp_sample_code.git
   cd mcp_sample_code
   ```

2. **Set up authentication:**
   ```bash
   export AUTH_CODE=your_secret_code_here
   ```

3. **Start the server:**
   ```bash
   ./start_mcp.sh
   ```

The script will automatically:
- Check for uv and ngrok installations
- Install dependencies
- Set up ngrok authentication (if needed)
- Start the MCP server
- Create a public tunnel
- Provide Claude.ai integration instructions

## Project Structure

```
mcp_sample_code/
├── pyproject.toml          # Project configuration and dependencies
├── sample_server.py        # Main MCP server implementation
├── start_mcp.sh           # Automated setup and deployment script
├── uv.lock               # Locked dependency versions
├── shared/               # Shared utilities
│   ├── __init__.py
│   └── auth_utils.py     # Authentication utilities
└── README.md             # This file
```

## API Endpoints

### `sample_server_version()`
Returns server version information and status.

**Response:**
```markdown
# Sample MCP Server

**Version**: 1.0.1
**Server ID**: SAMPLE_SERVER
**Status**: ✅ Active
```

### `get_logs()`
Retrieves simulated network switch logs with realistic entries.

**Response:**
```markdown
# Network Switch Logs

2024-01-15 14:23:45 INFO: Port 1/0/24 link up, 1000Mbps full duplex
2024-01-15 14:20:12 WARN: High CPU usage detected: 85%
2024-01-15 14:18:33 INFO: VLAN 100 configured on ports 1-12
2024-01-15 14:15:07 ERROR: Port 1/0/5 link down
2024-01-15 14:12:55 INFO: DHCP lease renewed for 192.168.1.45
2024-01-15 14:10:22 INFO: Spanning tree topology change detected
2024-01-15 14:08:11 WARN: Temperature threshold exceeded: 68°C
2024-01-15 14:05:45 INFO: Port 1/0/5 link up, 100Mbps full duplex
```

## Authentication

All API endpoints require authentication via the `AUTH_CODE` environment variable. The server validates requests and returns empty responses for unauthorized access.

### Setting Up Authentication

1. **Environment Variable:**
   ```bash
   export AUTH_CODE=your_secure_code
   ```

2. **URL Parameter (for Claude.ai):**
   ```
   https://your-ngrok-url.app?code=your_secure_code
   ```

## Integration with Claude.ai

1. **Start the server** with `./start_mcp.sh`
2. **Copy the provided URL** (includes auth code)
3. **In Claude.ai:**
   - Go to https://claude.ai/settings/integrations
   - Add MCP server with the provided URL
   - The server will be immediately available

## Configuration

### Environment Variables

- `AUTH_CODE`: Required authentication code
- `TRANSPORT`: Server transport type (default: "sse")
- `HOST`: Server host (default: "127.0.0.1")
- `MCP_PORT`: Server port (default: 8080)

### Server Configuration

The server runs on port 8080 by default and supports:
- **SSE Transport**: Server-Sent Events for real-time communication
- **Authentication**: All endpoints require valid auth code
- **CORS**: Configured for cross-origin requests
- **Error Handling**: Comprehensive error responses

## Development

### Local Development

1. **Install dependencies:**
   ```bash
   uv sync
   ```

2. **Set auth code:**
   ```bash
   export AUTH_CODE=dev_code
   ```

3. **Run server directly:**
   ```bash
   uv run python sample_server.py
   ```

### Adding New Endpoints

1. **Create a new tool function:**
   ```python
   @mcp.tool()
   async def your_new_tool() -> str:
       """Your tool description."""
       if not is_authorized():
           return ""
       
       # Your implementation here
       return "Your response"
   ```

2. **Update dependencies** if needed:
   ```bash
   uv add your-new-dependency
   ```

### Testing

The server includes comprehensive error handling and validation:
- Authentication checks on all endpoints
- Environment variable validation
- Dependency verification
- Connection health checks

## Dependencies

### Core Dependencies
- **fastmcp**: FastMCP framework for MCP protocol
- **httpx**: HTTP client for async requests
- **aiofiles**: Async file operations
- **sqlalchemy**: Database ORM (for future extensions)
- **psycopg2-binary**: PostgreSQL adapter
- **python-dotenv**: Environment variable management

### Additional Features
- **click**: CLI interface utilities
- **rich**: Rich text formatting
- **google-generativeai**: Google AI integration
- **diskcache**: Disk-based caching
- **markdownify**: HTML to Markdown conversion
- **beautifulsoup4**: HTML parsing
- **sparkpost**: Email service integration

### Development Dependencies
- **pytest**: Testing framework
- **pytest-asyncio**: Async testing support
- **black**: Code formatting
- **ruff**: Fast Python linter
- **mypy**: Static type checking

## Deployment

### Production Deployment

1. **Set production auth code:**
   ```bash
   export AUTH_CODE=production_secure_code
   ```

2. **Use production ngrok account** for stable URLs

3. **Configure monitoring** and logging as needed

### Docker Deployment (Future)

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY . .
RUN pip install uv && uv sync
CMD ["uv", "run", "python", "sample_server.py"]
```

## Troubleshooting

### Common Issues

1. **"AUTH_CODE not set" error:**
   ```bash
   export AUTH_CODE=your_code
   ```

2. **"uv not found" error:**
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

3. **"ngrok not authenticated" error:**
   - Get auth token from https://dashboard.ngrok.com/get-started/your-authtoken
   - Script will prompt for token setup

4. **Port already in use:**
   ```bash
   export MCP_PORT=8081
   ./start_mcp.sh
   ```

### Server Logs

The server provides detailed logging:
- Authentication attempts
- Tool invocations
- Error conditions
- Performance metrics

## Security Considerations

- **Authentication**: All endpoints require valid auth code
- **Input Validation**: All inputs are validated and sanitized
- **Error Handling**: Errors don't expose sensitive information
- **Transport Security**: HTTPS enforced via ngrok tunnels

## Contributing

1. **Fork the repository**
2. **Create a feature branch**
3. **Make your changes**
4. **Add tests** for new functionality
5. **Submit a pull request**

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- **GitHub Issues**: [Report bugs or request features](https://github.com/viorelspinu/mcp_sample_code/issues)
- **Documentation**: Check this README for comprehensive setup instructions
- **MCP Protocol**: [Official MCP Documentation](https://modelcontextprotocol.io/)

## Acknowledgments

- Built with [FastMCP](https://github.com/jlowin/fastmcp)
- Tunnel management via [ngrok](https://ngrok.com/)
- Package management with [uv](https://docs.astral.sh/uv/)
- Designed for [Claude.ai](https://claude.ai/) integration

---

**Made with ❤️ for the MCP community**
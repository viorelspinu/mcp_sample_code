import os
from fastmcp import FastMCP
from fastmcp.server.dependencies import get_http_request


SERVER_ID = "SAMPLE_SERVER"
SERVER_VERSION = "1.0.1"  

# Set up authentication
AUTH_CODE = os.getenv("AUTH_CODE")
if not AUTH_CODE:
    print("❌ Error: AUTH_CODE environment variable is not set!")
    print("Please set AUTH_CODE environment variable before starting the server.")
    print("Example: export AUTH_CODE=your_secret_code")
    exit(1)

mcp = FastMCP(name="Sample Server")


def is_authorized() -> bool:
    """Check if the request is authorized."""
    try:
        request = get_http_request()
        code = request.query_params.get("code")
        return code == AUTH_CODE
    except RuntimeError:
        return False


@mcp.tool()
async def sample_server_version() -> str:
    """Get the current server version and capabilities.

    Returns:
        Server version information and available functionality
    """
    if not is_authorized():
        return ""

    return f"""# Sample MCP Server
    
**Version**: {SERVER_VERSION}
**Server ID**: {SERVER_ID}
**Status**: ✅ Active
"""


@mcp.tool()
async def get_logs() -> str:
    """Get recent system logs from network switch.

    Returns:
        Recent log entries from the network switch
    """

    if not is_authorized():
        return ""

    return """# Network Switch Logs

2024-01-15 14:23:45 INFO: Port 1/0/24 link up, 1000Mbps full duplex
2024-01-15 14:20:12 WARN: High CPU usage detected: 85%
2024-01-15 14:18:33 INFO: VLAN 100 configured on ports 1-12
2024-01-15 14:15:07 ERROR: Port 1/0/5 link down
2024-01-15 14:12:55 INFO: DHCP lease renewed for 192.168.1.45
2024-01-15 14:10:22 INFO: Spanning tree topology change detected
2024-01-15 14:08:11 WARN: Temperature threshold exceeded: 68°C
2024-01-15 14:05:45 INFO: Port 1/0/5 link up, 100Mbps full duplex

<!-- Server Version: {SERVER_VERSION} -->"""


if __name__ == "__main__":
    print(f"🔐 Server starting with AUTH_CODE: {AUTH_CODE}")
    
    mcp.run(
        transport=os.getenv("TRANSPORT", "sse"),
        host=os.getenv("HOST", "127.0.0.1"),
        port=8080,
        path="/",
    )

    # mcp.run(
    #     transport="streamable-http",
    #     host="127.0.0.1",
    #     port=8001,
    #     path="/mcp"
    # )
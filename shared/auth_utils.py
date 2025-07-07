import os
import sys
from fastmcp.server.dependencies import get_http_request


def setup_auth(server_id: str) -> str:
    """Set up authentication for an MCP server.

    Args:
        server_id: The server identifier (e.g., "SAMPLE_SERVER")

    Returns:
        The auth code from environment variables

    Raises:
        SystemExit: If the auth code environment variable is not found
    """
    auth_code_env = f"{server_id}_AUTH_CODE"
    auth_code = os.getenv(auth_code_env)
    if not auth_code:
        print(f"Error: {auth_code_env} environment variable is required")
        sys.exit(1)
    return auth_code


def create_auth_validator(auth_code: str):
    """Create an authorization validator function.

    Args:
        auth_code: The expected authorization code

    Returns:
        A function that validates incoming requests
    """

    def is_authorized() -> bool:
        """Check if request has valid auth code"""
        try:
            request = get_http_request()
            code = request.query_params.get("code")
            is_valid = code == auth_code

            if not is_valid:
                print(
                    f"Auth failed - IP: {request.client.host if request.client else 'unknown'}, code: {code}"
                )

            return is_valid
        except RuntimeError:
            return True  # Allow CLI/testing
        except Exception as e:
            print(f"Auth error: {e}")
            return False

    return is_authorized
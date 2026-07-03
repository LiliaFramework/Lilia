from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import argparse
import os


class NoCacheRequestHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, directory=None, **kwargs):
        super().__init__(*args, directory=directory, **kwargs)

    def end_headers(self):
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        self.send_header("Clear-Site-Data", "\"cache\", \"storage\"")
        super().end_headers()


def main():
    parser = argparse.ArgumentParser(description="Serve a directory without browser caching.")
    parser.add_argument("--directory", default="site", help="Directory to serve")
    parser.add_argument("--host", default="127.0.0.1", help="Host to bind to")
    parser.add_argument("--port", type=int, default=8000, help="Port to bind to")
    args = parser.parse_args()

    directory = Path(args.directory).resolve()
    if not directory.exists():
        raise SystemExit(f"Directory does not exist: {directory}")

    os.chdir(directory)
    handler = lambda *handler_args, **handler_kwargs: NoCacheRequestHandler(
        *handler_args,
        directory=str(directory),
        **handler_kwargs,
    )
    server = ThreadingHTTPServer((args.host, args.port), handler)

    print(f'Serving "{directory}" at http://{args.host}:{args.port}')
    print("Caching disabled. Press Ctrl+C to stop the server.")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()

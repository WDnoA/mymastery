"""为 Flutter Web 构建提供 HTTP 服务，支持 WASM MIME 类型和跨域隔离头"""
import http.server
import os

PORT = 3000
DIR = os.path.join(os.path.dirname(__file__), "build", "web")

class FlutterWebHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIR, **kwargs)

    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        super().end_headers()

    extensions_map = {
        **http.server.SimpleHTTPRequestHandler.extensions_map,
        ".wasm": "application/wasm",
        ".js": "application/javascript",
        ".mjs": "application/javascript",
    }

if __name__ == "__main__":
    server = http.server.HTTPServer(("0.0.0.0", PORT), FlutterWebHandler)
    print(f"服务已启动: http://localhost:{PORT}")
    server.serve_forever()
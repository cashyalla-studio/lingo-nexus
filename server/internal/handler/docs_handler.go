package handler

import (
	_ "embed"
	"net/http"
)

//go:embed openapi.yaml
var openAPISpec []byte

// DocsHandler serves Swagger UI (dev-only).
func DocsHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.Write([]byte(swaggerHTML))
}

// OpenAPIHandler serves the raw OpenAPI 3.1 spec.
func OpenAPIHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/yaml")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Write(openAPISpec)
}

// swaggerHTML renders Scalar API reference (modern, beautiful alternative to Swagger UI).
// Scalar auto-fetches /openapi.yaml and renders the full interactive playground.
const swaggerHTML = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Scripta Sync API — Dev Console</title>
  <style>body { margin: 0; }</style>
</head>
<body>
  <script
    id="api-reference"
    data-url="/openapi.yaml"
    data-configuration='{"theme":"purple","layout":"modern","defaultHttpClient":{"targetKey":"javascript","clientKey":"fetch"}}'
  ></script>
  <script src="https://cdn.jsdelivr.net/npm/@scalar/api-reference"></script>
</body>
</html>`

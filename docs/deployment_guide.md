# Deployment Guide

## VPS
1. Copy the project to the server.
2. Install Flutter on a build runner or CI machine, then build the web or APK artifact outside the runtime server.
3. For the lightweight backend, install Node.js 20+ or Python 3.11+.
4. Export environment variables from `.env.example`.
5. Start the backend:
   - Node.js: `node backend/node/server.js`
   - Python: `python3 backend/python/server.py`
6. Reverse proxy the API with Nginx to `/api` and expose port 8080.

## cPanel
1. Upload `project_backup_v2.0.0.zip` via File Manager.
2. Extract into the application directory.
3. Use Setup Python App or Node.js Selector.
4. Set startup file to `backend/python/server.py` or `backend/node/server.js`.
5. Add environment variables from `.env.example`.
6. Point the Flutter web build output to `public_html` if web deployment is required.

## Docker
1. Build the container: `docker build -t recycle-market:2.0.0 .`
2. Run it: `docker run -d --name recycle-market -p 8080:8080 --env-file .env.example recycle-market:2.0.0`
3. Put Nginx or Traefik in front for TLS and domain routing.

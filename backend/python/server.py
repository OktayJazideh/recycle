from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse
import json
import os

PORT = int(os.environ.get('PORT', '8080'))

waste_types = [
    {"id": "paper", "title": "Paper & Cardboard", "titleFa": "کاغذ و کارتن", "iconName": "description", "colorHex": "#7D9B76", "pricePerKg": 15000, "isProtected": True},
    {"id": "plastic", "title": "Plastic", "titleFa": "پلاستیک", "iconName": "local_drink", "colorHex": "#5C8D89", "pricePerKg": 20000, "isProtected": True},
    {"id": "metal", "title": "Metal & Iron", "titleFa": "فلز و آهن", "iconName": "precision_manufacturing", "colorHex": "#8A6A4A", "pricePerKg": 45000, "isProtected": True},
    {"id": "copper", "title": "Copper & Brass", "titleFa": "مس و برنج", "iconName": "electrical_services", "colorHex": "#B06F4F", "pricePerKg": 350000, "isProtected": True},
    {"id": "glass", "title": "Glass", "titleFa": "شیشه", "iconName": "wine_bar", "colorHex": "#86B8A5", "pricePerKg": 5000, "isProtected": False},
    {"id": "electronics", "title": "Electronics", "titleFa": "الکترونیک", "iconName": "devices", "colorHex": "#7E8AA2", "pricePerKg": 30000, "isProtected": False},
]

approximate_amounts = [
    {"id": "q1", "label": "حدود ۵ کیلو", "sortOrder": 1},
    {"id": "q2", "label": "حدود ۱۰ کیلو", "sortOrder": 2},
    {"id": "q3", "label": "حدود ۲۰ کیلو", "sortOrder": 3},
    {"id": "q4", "label": "حدود ۵۰ کیلو", "sortOrder": 4},
    {"id": "q5", "label": "۱ کیسه", "sortOrder": 5},
    {"id": "q6", "label": "۲ کیسه", "sortOrder": 6},
    {"id": "q7", "label": "۳ جعبه", "sortOrder": 7},
]

settings = {"commissionPercent": 8.5, "maxDistanceKm": 10, "demoModeEnabled": True}
requests = []
ticket_messages = {"ticket-1": []}

class RecycleAPIHandler(BaseHTTPRequestHandler):
    def _send(self, status_code, payload):
        body = json.dumps(payload, ensure_ascii=False).encode('utf-8')
        self.send_response(status_code)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET,POST,PUT,OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
        self.wfile.write(body)

    def _read_json(self):
        length = int(self.headers.get('Content-Length', '0'))
        if length == 0:
            return {}
        return json.loads(self.rfile.read(length).decode('utf-8'))

    def do_OPTIONS(self):
        self._send(204, {})

    def do_GET(self):
        path = urlparse(self.path).path

        if path == '/health':
            return self._send(200, {"status": "ok", "service": "recycle-market-api"})
        if path == '/api/waste-types':
            return self._send(200, waste_types)
        if path == '/api/approximate-amounts':
            return self._send(200, approximate_amounts)
        if path == '/api/bootstrap':
            return self._send(200, {
                "users": [
                    {"id": "seller-demo", "name": "علی رضایی", "phone": "09121111111", "role": "seller", "address": "میدان ونک، تهران", "rating": 4.1, "completedOrders": 28, "preferredCategoryId": "paper", "points": 32},
                    {"id": "buyer-demo", "name": "مهدی (وانت سیار)", "phone": "09123334444", "role": "buyer", "address": "میدان ونک، تهران", "rating": 4.5, "completedOrders": 118, "preferredCategoryId": "metal", "vehicleInfo": "وانت زامیاد - سفید", "workingHours": "۸:۰۰ تا ۲۰:۰۰", "portfolioImages": ["assets/images/collector_before_after_1.png", "assets/images/collector_before_after_2.png"], "points": 84},
                    {"id": "admin-demo", "name": "مدیر سیستم", "phone": "09120000000", "role": "admin", "address": "دفتر مرکزی", "rating": 5, "completedOrders": 0, "preferredCategoryId": "paper"},
                ],
                "categories": waste_types,
                "quantityOptions": approximate_amounts,
                "settings": settings,
                "requests": requests,
                "tickets": [
                    {"id": "ticket-1", "title": "وزن ضایعات کمتر از اعلام اولیه بود", "status": "inProgress", "preview": "فروشنده ۲۰ کیلو اعلام کرده بود اما وزن واقعی کمتر بود.", "messages": ticket_messages.get('ticket-1', [])},
                ],
            })

        self._send(404, {"error": "Route not found"})

    def do_PUT(self):
        path = urlparse(self.path).path
        if path != '/api/settings':
            return self._send(404, {"error": "Route not found"})

        payload = self._read_json()
        incoming_settings = payload.get('settings', {})
        settings['commissionPercent'] = float(incoming_settings.get('commissionPercent', settings['commissionPercent']))
        settings['maxDistanceKm'] = float(incoming_settings.get('maxDistanceKm', settings['maxDistanceKm']))
        settings['demoModeEnabled'] = bool(incoming_settings.get('demoModeEnabled', settings['demoModeEnabled']))

        for incoming in payload.get('categories', []):
            for index, item in enumerate(waste_types):
                if item['id'] == incoming['id']:
                    waste_types[index] = {**item, **incoming, 'isProtected': item['isProtected'] or bool(incoming.get('isProtected', False))}
                    break

        self._send(200, {"success": True, "settings": settings, "categories": waste_types})

    def do_POST(self):
        path = urlparse(self.path).path
        payload = self._read_json()

        if path == '/api/requests':
            requests.insert(0, payload)
            return self._send(201, {"success": True, "request": payload})

        if path.startswith('/api/tickets/') and path.endswith('/messages'):
            ticket_id = path.split('/')[3]
            ticket_messages.setdefault(ticket_id, []).append(payload)
            return self._send(201, {"success": True, "ticketId": ticket_id, "message": payload})

        self._send(404, {"error": "Route not found"})

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', PORT), RecycleAPIHandler)
    print(f'Recycle market API running on http://localhost:{PORT}')
    server.serve_forever()

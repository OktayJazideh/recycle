const http = require('http');
const { URL } = require('url');

const PORT = process.env.PORT || 8080;

const wasteTypes = [
  { id: 'paper', title: 'Paper & Cardboard', titleFa: 'کاغذ و کارتن', iconName: 'description', colorHex: '#7D9B76', pricePerKg: 15000, isProtected: true },
  { id: 'plastic', title: 'Plastic', titleFa: 'پلاستیک', iconName: 'local_drink', colorHex: '#5C8D89', pricePerKg: 20000, isProtected: true },
  { id: 'metal', title: 'Metal & Iron', titleFa: 'فلز و آهن', iconName: 'precision_manufacturing', colorHex: '#8A6A4A', pricePerKg: 45000, isProtected: true },
  { id: 'copper', title: 'Copper & Brass', titleFa: 'مس و برنج', iconName: 'electrical_services', colorHex: '#B06F4F', pricePerKg: 350000, isProtected: true },
  { id: 'glass', title: 'Glass', titleFa: 'شیشه', iconName: 'wine_bar', colorHex: '#86B8A5', pricePerKg: 5000, isProtected: false },
  { id: 'electronics', title: 'Electronics', titleFa: 'الکترونیک', iconName: 'devices', colorHex: '#7E8AA2', pricePerKg: 30000, isProtected: false }
];

const approximateAmounts = [
  { id: 'q1', label: 'حدود ۵ کیلو', sortOrder: 1 },
  { id: 'q2', label: 'حدود ۱۰ کیلو', sortOrder: 2 },
  { id: 'q3', label: 'حدود ۲۰ کیلو', sortOrder: 3 },
  { id: 'q4', label: 'حدود ۵۰ کیلو', sortOrder: 4 },
  { id: 'q5', label: '۱ کیسه', sortOrder: 5 },
  { id: 'q6', label: '۲ کیسه', sortOrder: 6 },
  { id: 'q7', label: '۳ جعبه', sortOrder: 7 }
];

const settings = {
  commissionPercent: 8.5,
  maxDistanceKm: 10,
  demoModeEnabled: true,
};

const requests = [];
const ticketMessages = {};

function json(res, statusCode, payload) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,PUT,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type'
  });
  res.end(JSON.stringify(payload));
}

function parseBody(req) {
  return new Promise((resolve, reject) => {
    let raw = '';
    req.on('data', chunk => raw += chunk);
    req.on('end', () => {
      if (!raw) return resolve({});
      try { resolve(JSON.parse(raw)); } catch (error) { reject(error); }
    });
    req.on('error', reject);
  });
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);

  if (req.method === 'OPTIONS') return json(res, 204, {});

  if (req.method === 'GET' && url.pathname === '/health') {
    return json(res, 200, { status: 'ok', service: 'recycle-market-api' });
  }

  if (req.method === 'GET' && url.pathname === '/api/waste-types') {
    return json(res, 200, wasteTypes);
  }

  if (req.method === 'GET' && url.pathname === '/api/approximate-amounts') {
    return json(res, 200, approximateAmounts);
  }

  if (req.method === 'GET' && url.pathname === '/api/bootstrap') {
    return json(res, 200, {
      users: [
        { id: 'seller-demo', name: 'علی رضایی', phone: '09121111111', role: 'seller', address: 'میدان ونک، تهران', rating: 4.1, completedOrders: 28, preferredCategoryId: 'paper', points: 32 },
        { id: 'buyer-demo', name: 'مهدی (وانت سیار)', phone: '09123334444', role: 'buyer', address: 'میدان ونک، تهران', rating: 4.5, completedOrders: 118, preferredCategoryId: 'metal', vehicleInfo: 'وانت زامیاد - سفید', workingHours: '۸:۰۰ تا ۲۰:۰۰', portfolioImages: ['assets/images/collector_before_after_1.png', 'assets/images/collector_before_after_2.png'], points: 84 },
        { id: 'admin-demo', name: 'مدیر سیستم', phone: '09120000000', role: 'admin', address: 'دفتر مرکزی', rating: 5, completedOrders: 0, preferredCategoryId: 'paper' }
      ],
      categories: wasteTypes,
      quantityOptions: approximateAmounts,
      settings,
      requests,
      tickets: [
        { id: 'ticket-1', title: 'وزن ضایعات کمتر از اعلام اولیه بود', status: 'inProgress', preview: 'فروشنده ۲۰ کیلو اعلام کرده بود اما وزن واقعی کمتر بود.', messages: ticketMessages['ticket-1'] || [] }
      ]
    });
  }

  if (req.method === 'PUT' && url.pathname === '/api/settings') {
    const payload = await parseBody(req).catch(() => null);
    if (!payload) return json(res, 400, { error: 'Invalid JSON body' });

    settings.commissionPercent = Number(payload.settings?.commissionPercent ?? settings.commissionPercent);
    settings.maxDistanceKm = Number(payload.settings?.maxDistanceKm ?? settings.maxDistanceKm);
    settings.demoModeEnabled = Boolean(payload.settings?.demoModeEnabled ?? settings.demoModeEnabled);

    if (Array.isArray(payload.categories)) {
      payload.categories.forEach((incoming) => {
        const index = wasteTypes.findIndex(item => item.id === incoming.id);
        if (index >= 0) {
          wasteTypes[index] = { ...wasteTypes[index], ...incoming, isProtected: wasteTypes[index].isProtected || Boolean(incoming.isProtected) };
        }
      });
    }

    return json(res, 200, { success: true, settings, categories: wasteTypes });
  }

  if (req.method === 'POST' && url.pathname === '/api/requests') {
    const payload = await parseBody(req).catch(() => null);
    if (!payload) return json(res, 400, { error: 'Invalid JSON body' });
    requests.unshift(payload);
    return json(res, 201, { success: true, request: payload });
  }

  if (req.method === 'POST' && /^\/api\/tickets\/[^/]+\/messages$/.test(url.pathname)) {
    const ticketId = url.pathname.split('/')[3];
    const payload = await parseBody(req).catch(() => null);
    if (!payload) return json(res, 400, { error: 'Invalid JSON body' });
    ticketMessages[ticketId] = ticketMessages[ticketId] || [];
    ticketMessages[ticketId].push(payload);
    return json(res, 201, { success: true, ticketId, message: payload });
  }

  return json(res, 404, { error: 'Route not found' });
});

server.listen(PORT, () => {
  console.log(`Recycle market API running on http://localhost:${PORT}`);
});

// mock_server.js
const http = require('http');

let parcels = [
  {
    id: "urn:ngsi-ld:AgriParcel:Plot-01",
    name: "North Wheat Plot",
    cropType: "Wheat",
    soilMoisture: 18.2,
    soilTemperature: 25.4,
    valveId: "urn:ngsi-ld:AgriIrrigationValve:Valve-01",
    isValveOpen: false,
    boundaries: [
      { lat: 28.4080, lng: 77.3150 },
      { lat: 28.4080, lng: 77.3200 },
      { lat: 28.4120, lng: 77.3200 },
      { lat: 28.4120, lng: 77.3150 }
    ]
  },
  {
    id: "urn:ngsi-ld:AgriParcel:Plot-02",
    name: "South Mustard Field",
    cropType: "Mustard",
    soilMoisture: 32.5,
    soilTemperature: 24.1,
    valveId: "urn:ngsi-ld:AgriIrrigationValve:Valve-02",
    isValveOpen: true,
    boundaries: [
      { lat: 28.4020, lng: 77.3150 },
      { lat: 28.4020, lng: 77.3200 },
      { lat: 28.4060, lng: 77.3200 },
      { lat: 28.4060, lng: 77.3150 }
    ]
  },
  {
    id: "urn:ngsi-ld:AgriParcel:Plot-03",
    name: "East Rice Field",
    cropType: "Rice",
    soilMoisture: 48.0,
    soilTemperature: 22.8,
    valveId: "urn:ngsi-ld:AgriIrrigationValve:Valve-03",
    isValveOpen: false,
    boundaries: [
      { lat: 28.4050, lng: 77.3220 },
      { lat: 28.4050, lng: 77.3270 },
      { lat: 28.4090, lng: 77.3270 },
      { lat: 28.4090, lng: 77.3220 }
    ]
  }
];

const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, PATCH, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  // Root route "/" showing server status
  if (req.method === 'GET' && (req.url === '/' || req.url === '')) {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(`
      <body style="font-family: sans-serif; padding: 40px; background: #f4f6f8;">
        <h2>Mock Scorpio Gateway is Running!</h2>
        <p>API Endpoint: <a href="/api/v1/parcels">/api/v1/parcels</a></p>
        <pre style="background: #222; color: #00ff88; padding: 15px; border-radius: 8px;">${JSON.stringify(parcels, null, 2)}</pre>
      </body>
    `);
    return;
  }

  // GET /api/v1/parcels
  if (req.method === 'GET' && req.url === '/api/v1/parcels') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(parcels));
    return;
  }

  // PATCH /api/v1/entities/:id/attrs/status
  if (req.method === 'PATCH' && req.url.includes('/attrs/status')) {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      const data = JSON.parse(body);
      const urlParts = req.url.split('/');
      const entityId = decodeURIComponent(urlParts[4]);

      console.log(`[Scorpio Simulation] PATCH received for ${entityId}: status = ${data.value}`);

      parcels = parcels.map(p => {
        if (p.valveId === entityId) {
          return { ...p, isValveOpen: data.value === 'ON' };
        }
        return p;
      });

      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ message: "Updated entity attribute in Scorpio" }));
    });
    return;
  }

  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: "Route not found" }));
});

server.listen(5000, () => {
  console.log("Mock Scorpio Gateway running on http://localhost:5000");
});
Here is the complete, step-by-step runbook to start the entire Smart Agriculture system from a fresh clone on any machine.

---

### Prerequisites

Ensure the target machine has the following installed:

* **Git**
* **Docker Desktop** (running)
* **Node.js** ($\ge$ v18)
* **Flutter SDK** ($\ge$ v3.19)

---

### Phase 1: Start Scorpio Broker (Docker Stack)

Open **Terminal 1** (PowerShell or Bash) to spin up the Context Broker, Kafka event bus, and PostGIS database:

1. Create or navigate to your Docker directory:
```powershell
mkdir D:\scorpio_docker -ea 0
cd D:\scorpio_docker

```


2. Ensure your `docker-compose.yml` is present with the PostGIS, Kafka, Zookeeper, and Scorpio AAIO configurations.
3. Launch the container stack in the background:
```powershell
docker compose up -d

```


4. Verify all containers are healthy:
```powershell
docker compose ps

```


5. Seed sample `AgriParcel` context data into Scorpio:
```powershell
curl -i -X POST "http://localhost:9090/ngsi-ld/v1/entities/" `
  -H "Content-Type: application/ld+json" `
  -d '{
    "id": "urn:ngsi-ld:AgriParcel:Plot-01",
    "type": "AgriParcel",
    "name": { "type": "Property", "value": "North Wheat Plot" },
    "cropType": { "type": "Property", "value": "Wheat" },
    "soilMoisture": { "type": "Property", "value": 18.2 },
    "soilTemperature": { "type": "Property", "value": 25.4 },
    "valveId": { "type": "Property", "value": "urn:ngsi-ld:AgriIrrigationValve:Valve-01" },
    "isValveOpen": { "type": "Property", "value": false },
    "location": {
      "type": "GeoProperty",
      "value": {
        "type": "Polygon",
        "coordinates": [[
          [77.3150, 28.4080],
          [77.3200, 28.4080],
          [77.3200, 28.4120],
          [77.3150, 28.4120],
          [77.3150, 28.4080]
        ]]
      }
    },
    "@context": ["https://smart-data-models.github.io/data-models/context.jsonld"]
  }'

```



---

### Phase 2: Start the Gateway BFF Server

Open **Terminal 2** to run the translation gateway between Scorpio and the mobile app:

1. Navigate to your app directory:
```powershell
cd D:\agri_farmer_app

```


2. Start the gateway server (pointing to Scorpio at `http://localhost:9090`):
```powershell
node gateway_server.js

```


3. Verify the endpoint in your browser:
```text
http://localhost:5000/api/v1/parcels

```


*Expected Output:* A JSON array containing the seeded parcel details and coordinates.

---

### Phase 3: Setup & Run the Flutter Mobile App

Open **Terminal 3** to build and run the Flutter client:

1. Navigate to the project root:
```powershell
cd D:\agri_farmer_app

```


2. Fetch all project dependencies:
```powershell
flutter pub get

```


3. Generate the required Hive database adapters:
```powershell
dart run build_runner build --delete-conflicting-outputs

```


4. Verify target environment base URL in `lib/core/network/api_client.dart`:
* **Android Emulator:** `[http://10.0.2.2:5000](http://10.0.2.2:5000)`
* **Chrome / Windows Desktop:** `http://localhost:5000`
* **Physical Mobile Device:** `http://<YOUR_PC_WIFI_IP>:5000`


5. Launch the app:
```powershell
# For Web / Chrome testing:
flutter run -d chrome

# Or for connected Android device/emulator:
flutter run

```



---

### Verification Checklist

* **Map Renders:** ESRI satellite tiles auto-frame directly onto the farm coordinates.
* **Telemetry Displays:** North Wheat Plot shows glowing neon red boundary ($18.2\%$ moisture, critical warning).
* **Actuation Works:** Tapping **"TAP TO START WATER PUMP"** immediately switches the button to red (**"PUMP IS RUNNING"**), and Terminal 2 logs an outgoing `PATCH` request targeting Scorpio Broker.
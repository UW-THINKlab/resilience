# Configuration
A guide to configuring a new neighborhood for the resilience project.

### tl;dr
```
sudo mkdir -p /opt/resilience
sudo chown -r $USER /opt/resilience
git clone https://github.com/UW-THINKlab/resilience /opt/resilience
cd /opt/resilience

pixi run -e supabase start

cat <<EOF > neighborhood.json
{
    "neighborhood": "Somewhere",
    "location": [-124.108927, 46.887251],
    "bbox": [-124.161558, 46.846984, -124.068089, 46.914744],
    "supabaseUrl": "http://somewhere.example.com",
    "supabaseAnonKey": "insert-publishable-key"
}
EOF

pixi run -e supabase initialize neighborhood.json
pixi run -e frontend run
```

## 0. Preconditions
1. You have `git` installed for your platform.
2. You have `pixi` installed for your platform.
3. An external DNS name for the API.


## 1. Run Backend
```
sudo mkdir -p /opt/resilience
sudo chown -r $USER /opt/resilience
git clone https://github.com/UW-THINKlab/resilience /opt/resilience
cd /opt/resilience
pixi run -e supabase start
pixi run -e supabase status
```

## 2. Configure Neighborhood
Create a JSON file for your neighborhood. "Westport" will be used in this example, and `westport.json` contains:
```json
{
    "neighborhood": "Westport",
    "location": [-124.108927, 46.887251],
    "bbox": [-124.161558, 46.846984, -124.068089, 46.914744],
    "supabaseUrl": "http://westport.supportsphere.org",
    "supabaseAnonKey": "eyJhbGciO....sldwdXZGEo"
}
```

### 2.1 Expected Fields
#### `neighborhood`
The name of the location. Used generally in the app and messages.

#### `location`
The map coordinates of the center of the map. By default, this is shown as the center of the neighborhood map.

This location can be found using tools like https://bboxfinder.com.

[LON, LAT]

#### `bbox`
A bounding-box around the general area. This will be used for generating offline maps and feature sets.

This bounding-box can be found using tools like https://bboxfinder.com.

[MIN_LON, MIN_LAT, MAX_LON, MAX_LAT]

#### `supabaseUrl`
This is the external URL of the neighborhood backend system.

#### `supabaseAnonKey`
This is a secret key that enables the client to communicate with the API server.

It can read directly from Supabase backend using, on the backend host:
```
pixi run -e supabase status | grep PUBLISHABLE_KEY

PUBLISHABLE_KEY="sb_publishable_fDFGERFYEHdbfBEbefdFdsBD_3BJgxAaH"
```

### 3. Initialize Database
```
pixi run -e supabase initialize westport.json
```
This will:
- Generate offline map tiles for the configured area.
- Generate geocoding index for the configured area.
- FUTURE: Generate households and clusters for the for the configured area.
- Load database with generated datasets.
- Load map tiles and geocoding index.
- Create an initial admin user `admin`, and generate a secure password.
- Generate app configuration data.

**NOTE** This is only run once: When the system is initialized during the neighborhood setup process. Results are undefined if run against an already-initialized DB.

### 4. Build and Deploy Apps
Running the `initialize` step will create the resources needed to compile and deploy the apps.

To test locally:
```
pixi run -e frontend run
```

#### 4.1 Web
TDB - Build app and deploy to supabase S3. serve from supabase storage. TODO: Set up rev proxy for app, tiles and supabase API.

#### 4.2 iOS
TBD - Build and submit to app store. Link to Test Flight

#### 4.3 Android
TBD - Build APK. Link to side-loading APK
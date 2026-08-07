# Configuration
A guide to configuring a new neighborhood for the resilience project.

### tl;dr
```
sudo mkdir -p /opt/resilience
sudo chown -r $USER /opt/resilience
git clone https://github.com/UW-THINKlab/resilience /opt/resilience
cd /opt/resilience
git checkout messages

pixi run -e supabase initialize

pixi run -e frontend run
```

## 0. Preconditions
1. You have `git` installed.
2. You have [`pixi` installed](https://pixi.prefix.dev/latest/installation/).
3. You have [`flutter` installed](https://docs.flutter.dev/install) and `flutter docker` looks good.
4. An external DNS name for the API.


## 1. Initialize Backend
```
sudo mkdir -p /opt/resilience
sudo chown -r $USER /opt/resilience
git clone https://github.com/UW-THINKlab/resilience /opt/resilience
cd /opt/resilience
git checkout messages
pixi run -e supabase initialize
```
This will attempt to load values from `neighborhood.json`. If not present (by default), the initialization script 
will prompt the user for required values, and store everything in `neighborhood.json`.

```
What is the adminstrator's given name?  Paolo
What is the adminstrator's family name?  Ajax
What is the adminstrator's email?  ajax@example.com
What is the adminstrator's initial password?  myR@nd0mP4s$wd
Loaded DB seed data from /opt/resilience/seed.sql.gz
Created admin user
Wrote neighborhood config values to neighborhood.json
Generated dart config constants: src/support_sphere/lib/constants/appconfig.dart
```

## 1.1. neighborhood.json
The neighborhood file is use to configure the resilience node. It typically contains:
```json
{
    "neighborhood": "Westport",
    "location": [-124.108927, 46.887251],
    "supabaseUrl": "http://westport.supportsphere.org",
    "supabaseAnonKey": "eyJhbGciO....sldwdXZGEo"
    "given_name": "Paolo",
    "family_name": "Ajax",
    "email": "ajax@example.com",
}
```

### 1.1 Expected Fields
#### `neighborhood`
The name of the location. Used generally in the app and messages.

#### `location`
The map coordinates of the center of the map. By default, this is shown as the center of the neighborhood map.

This location can be found using tools like https://bboxfinder.com.

[LON, LAT]

#### `supabaseUrl`
This is the external URL of the neighborhood backend system.

#### `supabaseAnonKey`
This is a secret key that enables the client to communicate with the API server.

It can read directly from Supabase backend using, on the backend host:
```
pixi run -e supabase status | grep PUBLISHABLE_KEY

PUBLISHABLE_KEY="sb_publishable_fDFGERFYEHdbfBEbefdFdsBD_3BJgxAaH"
```

These fields can also be set using environment variables and the `--from_env` option of `scripts/appconfig.py`:
- `NEIGHBORHOOD_NAME`
- `NEIGHBORHOOD_LOCATION`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

#### `given_name`, `family_name`, `email`
These fields are used to create an initial administrator account. The login for that account is the email. 
The initialization script will prompt the user for a password.


### 2. Build and Deploy Apps
Running the `config` step will create the resources needed to compile and deploy the apps.

To test locally:
```
pixi run -e frontend run
```

#### 2.1 Web
Build the web app:
```
pixi run -e frontend build
```

To run the web app in a simple docker container:
```
docker compose up -d
```
and point your browser at http://localhost:8080

#### 2.2 iOS
TBD - Build and submit to app store. Link to Test Flight

#### 2.3 Android
TBD - Build APK. Link to side-loading APK

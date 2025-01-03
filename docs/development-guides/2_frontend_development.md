# Frontend Components

For the frontend application, we utilize Flutter.
It is an open-source UI software development kit created by Google.

This is used for the mobile and progressive web application development.

See [Official Documentation](https://flutter.dev/docs).

## Codebase

The app codebase can be found in the
[`src/support_sphere`](https://github.com/UW-THINKlab/resilience/tree/main/src/support_sphere) directory.

The codebase is structured as follows:

```console
.
├── android
├── ios
├── lib
│   ├── constants
│   ├── data
│   │   ├── enums
│   │   ├── models
│   │   ├── repositories
│   │   └── services
│   ├── logic
│   │   ├── bloc
│   │   │   └── auth
│   │   └── cubit
│   ├── presentation
│   │   ├── components
│   │   │   ├── auth
│   │   │   ├── checklist
│   │   │   └── home
│   │   ├── pages
│   │   │   ├── auth
│   │   │   └── main_app
│   │   │       ├── checklist
│   │   │       ├── home
│   │   │       ├── manage_resources
│   │   │       ├── profile
│   │   │       └── resource
│   │   └── router
│   │       └── flows
│   └── utils
├── linux
├── macos
├── test
│   └── unit_tests
└── web
```

**`android`**: A directory containing the Android project and any specific configurations.

**`ios`**: A directory containing the iOS project and any specific configurations.

**`lib`**: The codebase has been separated into modular directories to help separate
functionality and make to be easily maintainable.
The three main directories are `data`, `logic`, and `presentation`.
There are also `utils` and `constants` directories to store utility and constant files.
The main file that instantiates the app is `main.dart`.

- **`constants`**: A directory containing constants used throughout the app.
This will help in maintaining a single place to store all the constants used in the app, so that it can be easily updated and maintained.
- **`data`**: A directory containing data-related files for generating object models, definiting repository interface, and service interactions.
  - **`enums`**: A directory containing enums used throughout the app.
  - **`models`**: A directory containing models used throughout the app. These models are used to define the structure of the data that is being used in the app.
  - **`repositories`**: A directory containing repository interfaces used throughout the app. These interfaces are used to define the methods that will be used to interact with the data. This serves as a layer where the raw data from the services can be transformed into models that can be used by the app.
  - **`services`**: A directory containing services used throughout the app. These services are used to interact with the data sources, such as APIs or databases, to fetch the raw data that will be used in the app. The services interacts with the backend here via [Supabase's Flutter Client Library](https://supabase.com/docs/reference/dart/start).
- **`logic`**: A directory containing app logic-related files.
We are using the Dart [Bloc library](https://bloclibrary.dev/) to manage the state of the app. This helps in separating the UI from the business logic, making the app more maintainable and testable.
    - **`bloc`**: A directory containing blocs used throughout the app.
    A [bloc](https://bloclibrary.dev/bloc-concepts/#bloc) is an advance class that provide a way to manage the state of the app,
    and capture any event changes that occur in the app.
        - **`auth`**: A directory containing auth-related blocs.
    - **`cubit`**: A directory containing cubits used throughout the app.
    A [cubit](https://bloclibrary.dev/bloc-concepts/#cubit) is a simpler version of a bloc that is used to manage only the state of the app.
- **`presentation`**: A directory containing presentation-related files.
    - **`components`**: A directory containing UI components used throughout the app.
        - **`auth`**: A directory containing auth-related UI components.
        - **`checklist`**: A directory containing checklist-related UI components.
        - **`home`**: A directory containing home-related UI components.
    - **`pages`**: A directory containing pages used throughout the app.
        - **`auth`**: A directory containing auth-related pages.
        - **`main_app`**: A directory containing main app-related pages.
            - **`checklist`**: A directory containing checklist-related pages.
            - **`home`**: A directory containing home-related pages.
            - **`manage_resources`**: A directory containing manage resources-related pages.
            - **`profile`**: A directory containing profile-related pages.
            - **`resource`**: A directory containing resource-related pages.
    - **`router`**: A directory containing router-related files.
        - **`flows`**: A directory containing flows used throughout the app.
        We are using the Flutter [flow builder](https://pub.dev/packages/flow_builder) to help manage some of the navigation flow in the app.
- **`utils`**: A directory containing utility files used throughout the app.
**`linux`**: A directory containing the Linux specific configurations.
**`macos`**: A directory containing the macOS specific configurations.
**`test`**: A directory containing test-related files.
    - **`unit_tests`**: A directory containing unit tests.
**`web`**: A directory containing the web specific configurations.

## Running locally

To run this app locally, follow these steps:

0. Install [Pixi](https://github.com/prefix-dev/pixi?tab=readme-ov-file#installation)
1. In the package's directory, run the following to install `frontend`

   ```console
   # Install frontend tools
   pixi run -e frontend install-tools
   ```
2. Install [Android Studio](https://developer.android.com/studio)
3. Run Android Studio, which will help you install the Android toolchain. Be sure to include all required components
   1. Android SDK Platform
   2. Android SDK Command-line tools
   3. Android SDK Build-Tools
   4. Android SDK Platform-Tools
   5. Android Emulator

4. Accept the Android licenses (or check that you have already done so) and get frontend dependencies
   by running the command below. *There may be an issue indicated with XCode -- that is okay and can be ignored*
   
   ```console
   pixi run -e frontend setup-infra
   ```

5. Run Flutter. This will open the Android app in a new Chrome window.
You will need the supabase backend to be running in order to use the app.
See [Backend Components](./1_backend_development.md) for more information.
   
   To ensure the app connects to Supabase, set the `SUPABASE_URL` and `SUPABASE_ANON_KEY` with:

   ```console
   pixi run -e frontend flutter-run --dart-define=SUPABASE_ANON_KEY=secret.jwt.anonKeyValue --dart-define=SUPABASE_URL=http://localhost
   ```
   The credentials can be found in `deployment/values.dev.yaml`.

   At this point your frontend is now ready to go! You are all set.

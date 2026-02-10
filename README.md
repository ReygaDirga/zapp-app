<p align="center">
  <img src="https://assets.zapp.software/logo-with-title.png" height="100" alt="ZAPP! Logo" />
</p>

<p align="center">A mobile application for analyzing household electricity usage and promoting efficient, sustainable energy consumption.</p>
  <p align="center">
    <a href="LICENSE" target="_blank"><img src="https://img.shields.io/badge/license-GPL--3.0-green" alt="Package License" /></a>
    <a href="https://flutter.dev/" target="_blank"><img src="https://img.shields.io/badge/Flutter-3.9.2+-blue?logo=flutter" alt="Flutter" /></a>
    <a href="https://supabase.com/" target="_blank"><img src="https://img.shields.io/badge/Supabase-auth-3DD08F?logo=supabase" alt="Supabase"/></a>
  </p>

## Description

ZAPP! is a mobile application designed to help users understand, calculate, and analyze household electricity usage in a simple and structured way.  
By allowing users to organize their home into rooms and assign electrical appliances to each room, ZAPP! provides accurate estimations of electricity consumption based on real usage patterns.

The application records and visualizes electricity usage over daily, monthly, and yearly periods, enabling users to monitor trends and identify areas of excessive energy consumption.  
Through these insights, users are encouraged to make informed decisions to reduce unnecessary electricity usage and optimize energy efficiency in their homes.

In addition to calculation and monitoring features, ZAPP! also aims to raise awareness about sustainable energy practices.  
By presenting clear data and historical comparisons, the app helps users understand the impact of their daily habits on overall energy consumption, supporting a more responsible and eco-friendly lifestyle.

## Features

- **Electricity Usage Calculation**  
  Calculate electricity consumption based on rooms and electrical appliances added by users.

- **Room & Appliance Management**  
  Users can add multiple rooms and assign electrical devices to each room.

- **Usage History**  
  View saved electricity consumption history for:
  - Daily
  - Monthly
  - Yearly periods

- **Authentication System**  
  Secure user authentication powered by Supabase.


## How It Works

1. Users register or log in to the application.
2. Users add rooms in their house.
3. Users assign electrical appliances to each room.
4. The application calculates electricity usage based on appliance data.
5. Users can view the usage and history over different time periods.

## Tech Stack
| Category | Technology |
|----------|------------|
| Client   | Flutter    |
| Auth     | Supabase   |

## Installation

1. Clone the repository:

```bash
git clone https://github.com/darrentimotius/zapp-app.git
cd zapp-app
```

2. Install dependencies:

```bash
flutter pub get
```

3. Configure Supabase:

    Create a Supabase project and set up the required environment variables.

4. Run the application:

```bash
flutter run
```
## Environment Variables

To run this project, you will need to create .env file in the root folder and add the following environment variables:

`SUPABASE_URL`

`SUPABASE_ANON_KEY`


## License

ZAPP! is licensed under [GPL-3.0](LICENSE)


## Contributing

Contributions are always welcome!


Feel free to fork this repository, create a new branch, and submit a pull request.


## Authors

Developed by the **ZAPP! Team**.

| Name                         | GitHub Username |
|------------------------------|-----------------|
| Darren Timotius Raphael      | [@darrentimotius](https://github.com/darrentimotius) |
| Syarifana Amalia Putri       | [@syarifanaamalia](https://github.com/syarifanaamalia) |
| Rio Dwi Oktavianto           | [@ReygaDirga](https://github.com/ReygaDirga) |
| Nathaniel Christodeo Panget  | [@crimcrist](https://github.com/crimcrist) |
| Samuel Christian Chandra     | [@SamuelChris99](https://github.com/SamuelChris99) |
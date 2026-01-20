
# ZAPP!

ZAPP! is a mobile application designed to analyze household electricity usage and provide insightful information about energy consumption.  
The app also aims to educate users on the importance of efficient and sustainable energy usage.


## Features


- **Electricity Usage Calculation**  
  Calculate electricity consumption based on rooms and electrical appliances added by the user.

- **Room & Appliance Management**  
  Users can add multiple rooms and assign electrical devices to each room.

- **Usage History**  
  View saved  electricity consumption history for:
  - Daily
  - Monthly
  - Yearly periods

- **Authentication System**  
  Secure user authentication powered by Supabase.


## How It Works

1. User registers or logs in to the application.
2. User adds rooms in their house.
3. User adds electrical appliances to each room.
4. The app calculates electricity usage based on appliance data.
5. Users can view the usage and history over different time periods.
## Tech Stack
| Category | Technology |
|----------|------------|
| Client   | Flutter    |
| Server   | NestJS     |
| Auth     | Supabase   |
| Database | Supabase   |


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

    Create a Supabase project and setup the Environment Variables

4. Run the application:

```bash
flutter run
```
## Environment Variables

To run this project, you will need to create .env file on root folder and add the following environment variables to your .env file

`SUPABASE_URL`

`SUPABASE_ANON_KEY`


## License

ZAPP! is licensed under [GPL-3.0](https://choosealicense.com/licenses/gpl-3.0/)


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
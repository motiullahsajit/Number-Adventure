#!/bin/bash

API_KEY="749e653329bff5752709850321d33a27"

DEFAULT_LOCATION="Dhaka"
DEFAULT_TEMP_UNIT="metric"
DEFAULT_WIND_UNIT="m/s"

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -h, --help       Display this help message"
    echo "  -l, --location   Specify the location (e.g., city name, ZIP code, coordinates)"
    echo "  -t, --temperature-unit  Specify the temperature unit (Celsius or Fahrenheit)"
    echo "  -w, --wind-unit  Specify the wind speed unit (m/s or mph)"
    exit 1
}

set_user_preferences() {
    echo "User Preferences:"
    read -p "Enter default location: " DEFAULT_LOCATION
    read -p "Enter default temperature unit (Celsius or Fahrenheit): " DEFAULT_TEMP_UNIT
    read -p "Enter default wind speed unit (m/s or mph): " DEFAULT_WIND_UNIT
    # Save preferences to a configuration file
    echo "DEFAULT_LOCATION=\"$DEFAULT_LOCATION\"" > preferences.conf
    echo "DEFAULT_TEMP_UNIT=\"$DEFAULT_TEMP_UNIT\"" >> preferences.conf
    echo "DEFAULT_WIND_UNIT=\"$DEFAULT_WIND_UNIT\"" >> preferences.conf
    echo "Preferences saved."
}

load_user_preferences() {
    if [ -f "preferences.conf" ]; then
        source "preferences.conf"
    fi
}

get_weather() {
    load_user_preferences

    if [ -z "$LOCATION" ]; then
        LOCATION="$DEFAULT_LOCATION"
    fi

    API_URL="http://api.openweathermap.org/data/2.5/weather?q=$LOCATION&appid=$API_KEY&units=$DEFAULT_TEMP_UNIT"

    wget -qO- "$API_URL" > weather_data.json

    if [ $? -ne 0 ]; then
        echo "Error fetching weather data. Please check your internet connection or API key."
        exit 1
    fi

    description=$(grep -o '"description":"[^"]*' weather_data.json | cut -d'"' -f4)
    temperature=$(grep -o '"temp":[^,]*' weather_data.json | cut -d':' -f2)
    humidity=$(grep -o '"humidity":[^,]*' weather_data.json | cut -d':' -f2)
    wind_speed=$(grep -o '"speed":[^,]*' weather_data.json | cut -d':' -f2)
    wind_deg=$(grep -o '"deg":[^,]*' weather_data.json | cut -d':' -f2)

    echo "Location: $LOCATION"
    echo "Description: $description"
    echo "Temperature: $temperature°C"
    echo "Humidity: $humidity%"
    echo "Wind Speed: $wind_speed $DEFAULT_WIND_UNIT"
    echo "Wind Direction: $wind_deg°"

    rm weather_data.json
}

show_main_menu() {
    while true; do
        echo "Weather Information Menu:"
        echo "1. Current Weather"
        echo "2. Set User Preferences"
        echo "3. Enter Custom Location"
        echo "4. Exit"
        read -p "Select an option (1/2/3/4): " choice
        case "$choice" in
            1) get_weather ;;
            2) set_user_preferences ;;
            3) read -p "Enter custom location: " LOCATION; get_weather ;;
            4) exit ;;
            *) echo "Invalid choice. Please select a valid option." ;;
        esac
    done
}

show_main_menu

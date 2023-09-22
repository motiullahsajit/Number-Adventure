#!/bin/bash

# Replace 'YOUR_API_KEY' with your OpenWeatherMap API key
API_KEY="749e653329bff5752709850321d33a27"

# Default values
DEFAULT_LOCATION="New York"
DEFAULT_TEMP_UNIT="metric"
DEFAULT_WIND_UNIT="m/s"

# Function to display usage instructions
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -h, --help       Display this help message"
    echo "  -l, --location   Specify the location (e.g., city name, ZIP code, coordinates)"
    echo "  -t, --temperature-unit  Specify the temperature unit (Celsius or Fahrenheit)"
    echo "  -w, --wind-unit  Specify the wind speed unit (m/s or mph)"
    exit 1
}

# Function to set user preferences
set_user_preferences() {
    echo "User Preferences:"
    read -p "Enter default location: " DEFAULT_LOCATION
    read -p "Enter default temperature unit (Celsius or Fahrenheit): " DEFAULT_TEMP_UNIT
    read -p "Enter default wind speed unit (m/s or mph): " DEFAULT_WIND_UNIT
}

# Function to fetch and display weather information
get_weather() {
    # Check if the location is specified; otherwise, use the default location
    if [ -z "$LOCATION" ]; then
        LOCATION="$DEFAULT_LOCATION"
    fi

    # API URL for fetching weather data
    API_URL="http://api.openweathermap.org/data/2.5/weather?q=$LOCATION&appid=$API_KEY&units=$DEFAULT_TEMP_UNIT"

    # Use wget to fetch weather data from OpenWeatherMap API
    wget -qO- "$API_URL" > weather_data.json

    # Check if there was an error fetching data
    if [ $? -ne 0 ]; then
        echo "Error fetching weather data. Please check your internet connection or API key."
        exit 1
    fi

    # Parse the JSON response to get relevant weather information
    description=$(grep -o '"description":"[^"]*' weather_data.json | cut -d'"' -f4)
    temperature=$(grep -o '"temp":[^,]*' weather_data.json | cut -d':' -f2)
    humidity=$(grep -o '"humidity":[^,]*' weather_data.json | cut -d':' -f2)
    wind_speed=$(grep -o '"speed":[^,]*' weather_data.json | cut -d':' -f2)
    wind_deg=$(grep -o '"deg":[^,]*' weather_data.json | cut -d':' -f2)

    # Display weather information
    echo "Location: $LOCATION"
    echo "Description: $description"
    echo "Temperature: $temperature°C"
    echo "Humidity: $humidity%"
    echo "Wind Speed: $wind_speed $DEFAULT_WIND_UNIT"
    echo "Wind Direction: $wind_deg°"

    # Clean up the temporary JSON file
    rm weather_data.json
}

# Function to fetch and display weather forecast
get_forecast() {
    # Check if the location is specified; otherwise, use the default location
    if [ -z "$LOCATION" ]; then
        LOCATION="$DEFAULT_LOCATION"
    fi

    # API URL for fetching weather forecast data
    API_URL="http://api.openweathermap.org/data/2.5/forecast?q=$LOCATION&appid=$API_KEY&units=$DEFAULT_TEMP_UNIT"

    # Use wget to fetch weather forecast data from OpenWeatherMap API
    wget -qO- "$API_URL" > forecast_data.json

    # Check if there was an error fetching data
    if [ $? -ne 0 ]; then
        echo "Error fetching weather forecast data. Please check your internet connection or API key."
        exit 1
    fi

    # Parse the JSON response to get forecast information
    # Display forecast for the upcoming days
    echo "Weather Forecast for $LOCATION:"
    cat forecast_data.json | grep -A 3 '"dt_txt": "'$(date +'%Y-%m-%d') | grep -E 'description|temp'

    # Clean up the temporary JSON file
    rm forecast_data.json
}

# Function to display the main menu
show_main_menu() {
    while true; do
        echo "Weather Information Menu:"
        echo "1. Current Weather"
        echo "2. Weather Forecast"
        echo "3. Set User Preferences"
        echo "4. Exit"
        read -p "Select an option (1/2/3/4): " choice
        case "$choice" in
            1) get_weather ;;
            2) get_forecast ;;
            3) set_user_preferences ;;
            4) exit ;;
            *) echo "Invalid choice. Please select a valid option." ;;
        esac
    done
}

# Call the function to display the main menu
show_main_menu

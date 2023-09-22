#!/bin/bash

# Replace 'YOUR_API_KEY' with your OpenWeatherMap API key
API_KEY="749e653329bff5752709850321d33a27"

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

# Default values
LOCATION=""
TEMP_UNIT="metric" # Default to Celsius
WIND_UNIT="m/s"    # Default to meters per second

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_usage
            ;;
        -l|--location)
            LOCATION="$2"
            shift 2
            ;;
        -t|--temperature-unit)
            TEMP_UNIT="$2"
            shift 2
            ;;
        -w|--wind-unit)
            WIND_UNIT="$2"
            shift 2
            ;;
        *)
            echo "Invalid option: $1"
            show_usage
            ;;
    esac
done

# Check if the location is specified
if [ -z "$LOCATION" ]; then
    read -p "Enter location (e.g., city name, ZIP code, coordinates): " LOCATION
fi

# Check if the temperature unit is specified
if [ -z "$TEMP_UNIT" ]; then
    read -p "Enter temperature unit (Celsius or Fahrenheit): " TEMP_UNIT
fi

# Check if the wind unit is specified
if [ -z "$WIND_UNIT" ]; then
    read -p "Enter wind speed unit (m/s or mph): " WIND_UNIT
fi

# API URL for fetching weather data
API_URL="http://api.openweathermap.org/data/2.5/weather?q=$LOCATION&appid=$API_KEY&units=$TEMP_UNIT"

# Function to fetch and display weather information
get_weather() {
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
    echo "Wind Speed: $wind_speed $WIND_UNIT"
    echo "Wind Direction: $wind_deg°"

    # Clean up the temporary JSON file
    rm weather_data.json
}

# Call the function to get and display weather information
get_weather

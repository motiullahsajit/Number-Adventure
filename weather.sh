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
    # Use cURL to fetch weather data from OpenWeatherMap API
    weather_data=$(curl -s "$API_URL")

    # Check if there was an error fetching data
    if [ $? -ne 0 ]; then
        echo "Error fetching weather data. Please check your internet connection or API key."
        exit 1
    fi

    # Parse the JSON response to get relevant weather information
    description=$(echo "$weather_data" | jq -r '.weather[0].description')
    temperature=$(echo "$weather_data" | jq -r '.main.temp')
    humidity=$(echo "$weather_data" | jq -r '.main.humidity')
    wind_speed=$(echo "$weather_data" | jq -r '.wind.speed')
    wind_deg=$(echo "$weather_data" | jq -r '.wind.deg')

    # Display weather information
    echo "Location: $LOCATION"
    echo "Description: $description"
    echo "Temperature: $temperature°C"
    echo "Humidity: $humidity%"
    echo "Wind Speed: $wind_speed $WIND_UNIT"
    echo "Wind Direction: $wind_deg°"
}

# Call the function to get and display weather information
get_weather

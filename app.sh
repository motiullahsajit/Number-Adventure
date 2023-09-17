#!/bin/bash

generate_random_number() {
  local min=$1
  local max=$2
  echo $((RANDOM % (max - min + 1) + min))
}

send_message() {
  local message="$1"
  echo "$message" > /dev/tcp/$opponent_ip/$opponent_port
}

receive_message() {
  nc -l -p $player_port
}

display_menu() {
  clear
  echo "Number Guessing Adventure - Multiplayer Edition"
  echo "1. Single Player"
  echo "2. Multiplayer"
  echo "3. Instructions"
  echo "4. Leaderboard"
  echo "5. Quit"
}

display_instructions() {
  clear
  echo "Instructions:"
  echo "- This is a number guessing game combined with Linux shell commands."
  echo "- In single-player mode, guess the number to earn points."
  echo "- In multiplayer mode, compete or collaborate with others."
  echo "- Use Linux commands to solve puzzles and advance in the game."
  echo "- Check leaderboards for your ranking."
  echo "- Have fun and learn Linux commands!"
  read -p "Press Enter to go back to the menu..."
}

display_leaderboard() {
  clear
  echo "Local Leaderboard:"
  echo "Player 1 Score: $player1_score"
  echo "Player 2 Score: $player2_score"
  read -p "Press Enter to continue..."
}

play_game() {
  local min=$1
  local max=$2
  local secret_number=$(generate_random_number $min $max)
  local attempts=0
  local score=0

  while true; do
    read -p "Guess the number between $min and $max: " guess
    ((attempts++))

    if [[ $guess -lt $secret_number ]]; then
      echo "Try higher!"
    elif [[ $guess -gt $secret_number ]]; then
      echo "Try lower!"
    else
      echo "Congratulations! You guessed the number $secret_number in $attempts attempts."
      score=$((100 - attempts))
      echo "Your score: $score"
      break
    fi
  done
}

play_multiplayer_game() {
  clear
  echo "Multiplayer Mode"
  echo "Waiting for another player to join..."
  echo "Share the following information with the other player:"
  echo "Your IP: $my_ip"
  echo "Your Port: $my_port"

  echo "1. Host a game"
  echo "2. Join a game"
  read -p "Select an option: " mp_option

  case $mp_option in
    1)
      player_number=1
      player_port=$my_port
      opponent_ip=""
      opponent_port=""

      opponent_ip=$(receive_message)
      opponent_port=$(receive_message)
      echo "Player 2 has joined the game."
      ;;
    2)
      player_number=2
      player_port=$my_port
      opponent_ip=$opponent_ip
      opponent_port=$opponent_port

      send_message "$my_ip"
      send_message "$my_port"
      echo "Connected to Player 1."
      ;;
    *)
      echo "Invalid option. Please choose 1 or 2."
      return
      ;;
  esac

  local min=1
  local max=100
  local secret_number=$(generate_random_number $min $max)
  local attempts=0
  local score=0

  while true; do
    read -p "Player $player_number, guess the number between $min and $max: " guess
    ((attempts++))

    if [[ $guess -lt $secret_number ]]; then
      echo "Try higher!"
    elif [[ $guess -gt $secret_number ]]; then
      echo "Try lower!"
    else
      echo "Player $player_number, you guessed the number $secret_number in $attempts attempts."
      score=$((100 - attempts))
      echo "Your score: $score"

      send_message "Player $player_number has guessed the number in $attempts attempts with a score of $score."

      break
    fi
  done
}

my_ip=$(hostname -I | awk '{print $1}')
my_port=$(shuf -i 1024-49151 -n 1)
player1_score=0
player2_score=0

while true; do
  display_menu

  read -p "Select an option: " choice

  case $choice in
    1)
      clear
      echo "Choose a Difficulty Level:"
      echo "1. Easy (1-50)"
      echo "2. Medium (1-100)"
      echo "3. Hard (1-200)"
      echo "4. Very Hard (1-300)"
      echo "5. Insane (1-500)"
      read -p "Select a difficulty level: " difficulty_choice

      case $difficulty_choice in
        1)
          play_game 1 50
          ;;
        2)
          play_game 1 100
          ;;
        3)
          play_game 1 200
          ;;
        4)
          play_game 1 300
          ;;
        5)
          play_game 1 500
          ;;
        *)
          echo "Invalid difficulty level. Please choose 1, 2, 3, 4, or 5."
          ;;
      esac
      ;;
    2)
      play_multiplayer_game
      ;;
    3)
      display_instructions
      ;;
    4)
      display_leaderboard
      ;;
    5)
      echo "Thanks for playing! Goodbye."
      exit
      ;;
    *)
      echo "Invalid option. Please choose 1, 2, 3, 4, or 5."
      ;;
  esac
done

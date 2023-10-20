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

declare -A user_profiles

create_user_profile() {
  read -p "Enter a new user ID: " user_id
  read -s -p "Enter a passcode: " passcode
  echo

  echo "$user_id:$passcode:0" >> user_profiles.txt

  echo "User profile created for user ID: $user_id"
}

authenticate_user() {
  read -p "Enter your user ID: " user_id
  read -s -p "Enter your passcode: " passcode
  echo

  if grep -q "^$user_id:$passcode:" user_profiles.txt; then
    echo "Authentication successful. Welcome, $user_id!"
    return 0
  else
    echo "Authentication failed. Invalid user ID or passcode."
    return 1
  fi
}

update_leaderboard() {
  local user_id="$1"
  local score="$2"

  sed -i "s/^$user_id:[0-9]*$/$user_id:$score/" leaderboard.txt
}

# Function to display the leaderboard
display_leaderboard() {
  clear
  echo "Local Leaderboard:"
  sort -t: -k2,2nr leaderboard.txt | while IFS=: read -r user_id score; do
    echo "Player $user_id Score: $score"
  done
  read -p "Press Enter to continue..."
}

play_game() {
  local min=$1
  local max=$2
  local secret_number=$(generate_random_number $min $max)
  local attempts=0
  local score=0
  local time_limit=60

  echo "You have $time_limit seconds to guess the number between $min and $max."

  local start_time=$(date +%s)

  while true; do
    read -t $time_limit -p "Guess the number between $min and $max: " guess

    local current_time=$(date +%s)
    local elapsed_time=$((current_time - start_time))

    if [ $? -ne 0 ]; then
      echo "Time's up! You didn't guess in time."
      break
    fi

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

    if [ $elapsed_time -ge $time_limit ]; then
      echo "Time's up! You didn't guess in time."
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

# Function to play the NumberJack game
play_numberjack_game() {
  clear
  echo "Welcome to NumberJack Game!"
  ch=0

  while [ $ch -ne 3 ]; do
    echo "NumberJack Menu:"
    echo "1. Play NumberJack"
    echo "2. Instructions"
    echo "3. Return to Main Menu"
    read -p "Enter your choice: " ch

    case $ch in
      1)
        x=0
        c=0
        p=0
        read -p "Enter any number between 0 and 9: " n
        while [ $c -eq 0 ]; do
          x=11
          r=($(shuf -i 0-9 -n 10))
          echo "${r[@]} "
          for i in {1..10}; do
            a[$i]=$i
          done
          echo "${a[@]} "
          read -t 5 -p "Enter the index of your number: " x
          if [[ $? -gt 128 ]]; then
            c=1
            break
          fi
          if [ ${r[$(($x))-1]} -eq $n ]; then
            echo "Great"
            ((p=p+1))
          else
            c=1
            break
          fi
        done
        ;;
      2)
        echo "HELP: INSTRUCTIONS TO PLAY THE NUMBERJACK GAME. "
        echo "1. Select any number between 0 and 9 (inclusive) i.e 0 and 9 are accepted."
        echo "2. Two lists will appear in front of you."
        echo "3. The upper list will have a list of randomly shuffled numbers between 0 and 9."
        echo "4. See if you can find your chosen number in that list within 5 seconds."
        echo "5. Then you have to enter the index of that number indicated in the second list below."
        echo "6. The game will continue until you are correct and enter the number on time (before 5 sec)."
        ;;
      3)
        break
        ;;
      *)
        echo "Invalid choice. Please select a valid option."
        ;;
    esac

    if [ $c -eq 1 ]; then
      echo -e "\nGAME OVER\n"
      echo "You scored $p points"
    fi
  done
}

my_ip=$(hostname -I | awk '{print $1}')
my_port=$(shuf -i 1024-49151 -n 1)

leaderboard_file="leaderboard.txt"
if [ ! -f "$leaderboard_file" ]; then
  touch "$leaderboard_file"
  echo "1:0" >> "$leaderboard_file"
  echo "2:0" >> "$leaderboard_file"
fi

while true; do
  clear
  echo "Number Guessing Adventure - Multiplayer Edition"
  echo "1. Single Player"
  echo "2. Multiplayer"
  echo "3. Instructions"
  echo "4. Leaderboard"
  echo "5. Create User Profile"
  echo "6. Login"
  echo "7. NumberJack Game"
  echo "8. Quit"
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
      clear
      echo "Instructions:"
      echo "- This is a number guessing game combined with Linux shell commands."
      echo "- In single-player mode, guess the number to earn points."
      echo "- In multiplayer mode, compete or collaborate with others."
      echo "- Use Linux commands to solve puzzles and advance in the game."
      echo "- Check leaderboards for your ranking."
      echo "- Have fun and learn Linux commands!"
      read -p "Press Enter to go back to the menu..."
      ;;
    4)
      display_leaderboard
      ;;
    5)
      create_user_profile
      ;;
    6)
      authenticate_user
      if [ $? -eq 0 ]; then
        echo "Press Enter to continue..."
        read

        play_game 1 100

        update_leaderboard "$user_id" "$score"
      else
        echo "Press Enter to go back to the menu..."
        read
      fi
      ;;
    7)
      play_numberjack_game
      ;;
    8)
      echo "Thanks for playing! Goodbye."
      exit
      ;;
    *)
      echo "Invalid option. Please choose a valid option."
      ;;
  esac
done

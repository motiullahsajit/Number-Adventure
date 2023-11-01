#!/bin/bash

declare -a board=(
    5 3 0 0 7 0 0 0 0
    6 0 0 1 9 5 0 0 0
    0 9 8 0 0 0 0 6 0
    8 0 0 0 6 0 0 0 3
    4 0 0 8 0 3 0 0 1
    7 0 0 0 2 0 0 0 6
    0 6 0 0 0 0 2 8 0
    0 0 0 4 1 9 0 0 5
    0 0 0 0 8 0 0 7 9
)

print_board() {
    echo -e "Sudoku Board:"
    for ((row=0; row<9; row++)); do
        for ((col=0; col<9; col++)); do
            echo -n "${board[row*9 + col]} "
            if [ $(((col + 1) % 3)) -eq 0 ] && [ $col -lt 8 ]; then
                echo -n "| "
            fi
        done
        echo
        if [ $(((row + 1) % 3)) -eq 0 ] && [ $row -lt 8 ]; then
            echo "------+-------+------"
        fi
    done
}

is_valid_move() {
    local row=$1
    local col=$2
    local num=$3

    for ((i=0; i<9; i++)); do
        if [ "${board[row*9 + i]}" -eq "$num" ] || [ "${board[i*9 + col]}" -eq "$num" ]; then
            return 1
        fi
    done

    local box_start_row=$((row - row % 3))
    local box_start_col=$((col - col % 3))

    for ((i=box_start_row; i<box_start_row+3; i++)); do
        for ((j=box_start_col; j<box_start_col+3; j++)); do
            if [ "${board[i*9 + j]}" -eq "$num" ]; then
                return 1
            fi
        done
    done

    return 0
}

is_solved() {
    for ((row=0; row<9; row++)); do
        for ((col=0; col<9; col++)); do
            if [ "${board[row*9 + col]}" -eq 0 ]; then
                return 1
            fi
        done
    done

    return 0
}

play_sudoku() {
    while true; do
        print_board
        echo -e "Enter row (1-9) and column (1-9) to place a number (0 to quit):"
        read -p "Row: " row
        read -p "Column: " col

        if [ "$row" -eq 0 ] || [ "$col" -eq 0 ]; then
            echo "Exiting Sudoku game."
            break
        fi

        if [ "$row" -ge 1 ] && [ "$row" -le 9 ] && [ "$col" -ge 1 ] && [ "$col" -le 9 ] && [ "${board[((row-1)*9 + col-1)]}" -eq 0 ]; then
            read -p "Enter a number (1-9): " number
            if is_valid_move $((row-1)) $((col-1)) "$number"; then
                board[((row-1)*9 + col-1)]="$number"
            else
                echo "Invalid move. Try again."
            fi
        else
            echo "Invalid row or column. Try again."
        fi

        if is_solved; then
            print_board
            echo "Congratulations! You've solved the Sudoku puzzle!"
            break
        fi
    done
}

print_menu() {
    while true; do
        echo -e "\nSudoku Game Menu:"
        echo "1. Play Sudoku"
        echo "2. Exit"
        read -p "Enter your choice: " choice

        case "$choice" in
            1)
                play_sudoku
                ;;
            2)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Invalid choice. Please select a valid option."
                ;;
        esac
    done
}

print_menu

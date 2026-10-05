#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')" > /dev/null
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  STATS=$($PSQL "SELECT COUNT(*), MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID")
  IFS='|' read GAMES_PLAYED BEST_GAME <<< "$STATS"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
NUMBER_OF_GUESSES=0

while true
do
  read GUESS || exit 1

  if [[ ! $GUESS =~ ^-?[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  (( NUMBER_OF_GUESSES++ ))

  if [ "$GUESS" -gt "$SECRET_NUMBER" ]
  then
    echo "It's lower than that, guess again:"
  elif [ "$GUESS" -lt "$SECRET_NUMBER" ]
  then
    echo "It's higher than that, guess again:"
  else
    break
  fi
done

$PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)" > /dev/null

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
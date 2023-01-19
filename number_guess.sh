#!/bin/bash

GUESS(){
  #Note that by default all variables are global in bash.
  read NUMBER_GUESS
  while [[ ! $NUMBER_GUESS =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read NUMBER_GUESS
  done
}

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUMBER=$(( $RANDOM % 1000 + 1))
echo $NUMBER
#Ask for name
echo "Enter your username:"
read NAME
NAME_FOUND=$($PSQL "SELECT player FROM game_list WHERE player = '$NAME'")
#If not found
if [[ -z $NAME_FOUND ]]
then 
  echo "Welcome, $NAME! It looks like this is your first time here."

#If found
else
  TOTAL_GAMES_PLAYED=$($PSQL "SELECT count(*) FROM game_list WHERE player = '$NAME'")
  MIN_PREVIOUS_ATTEMPTS=$($PSQL "SELECT MIN(attempts) FROM game_list WHERE player = '$NAME'")
  echo "Welcome back, $NAME! You have played $TOTAL_GAMES_PLAYED games, and your best game took $MIN_PREVIOUS_ATTEMPTS guesses."
fi

echo "Guess the secret number between 1 and 1000:"
GUESS
ATTEMPTS=1
while [[ $NUMBER_GUESS -ne $NUMBER ]]
do
  if [[ $NUMBER_GUESS -gt $NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  
  ATTEMPTS=$(($ATTEMPTS+1))
  GUESS
  
done
echo "You guessed it in $ATTEMPTS tries. The secret number was $NUMBER. Nice job!"
GAME_RESULT=$($PSQL "INSERT INTO game_list(player, attempts) VALUES('$NAME', $ATTEMPTS)")
#!/bin/bash

PSQL="psql -U freecodecamp -d periodic_table -t -A -F '|' -c"

# Check for argument
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

ARG="$1"

# Query element info
RESULT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
FROM elements e
JOIN properties p ON e.atomic_number = p.atomic_number
JOIN types t ON p.type_id = t.type_id
WHERE e.atomic_number::text = '$ARG' OR e.symbol ILIKE '$ARG' OR e.name ILIKE '$ARG';")

# Check if element exists
if [[ -z $RESULT ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

# Split into variables
IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELT BOIL <<< "$RESULT"

# Remove any single quotes from each variable
ATOMIC_NUMBER=${ATOMIC_NUMBER//\'/}
NAME=${NAME//\'/}
SYMBOL=${SYMBOL//\'/}
TYPE=${TYPE//\'/}
MASS=${MASS//\'/}
MELT=${MELT//\'/}
BOIL=${BOIL//\'/}

# Print exactly in FCC format
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."

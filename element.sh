#!/bin/bash

PSQL="psql -U freecodecamp -d periodic_table -t -A -F '|' -c"

# If no argument is provided
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

# If element not found
if [[ -z $RESULT ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

# Remove any surrounding whitespace or quotes
RESULT=$(echo $RESULT | tr -d "'\"")

# Split result into variables
IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELT BOIL <<< "$RESULT"

# Capitalize first letter of symbol only
SYMBOL="$(tr '[:lower:]' '[:upper:]' <<< ${SYMBOL:0:1})${SYMBOL:1}"

# Remove trailing zeros from numeric values
trim_trailing() {
  printf "%s" "$1" | sed -E 's/\.?0+$//'
}

MASS=$(trim_trailing "$MASS")
MELT=$(trim_trailing "$MELT")
BOIL=$(trim_trailing "$BOIL")

# Print exactly in FCC format
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."

#!/bin/bash

LIMIT=10
LIST=false

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      echo "-c NUMBER, --checkout=NUMBER   specify the number of the branch you want to checkout"
      echo "-h, --help                     show available options"
      echo "-l, --list                     show list of branches, without selecting one to checkout"
			echo "-n NUMBER, --number=NUMBER     specify the maximum number of branches you want to list"
      exit 0
      ;;
    -c)
      shift
      if [ $# -gt 0 ]; then
        export BRANCH_NR=$1
      else
        echo "no branch number specified"
        exit 1
      fi
      ;;
    --checkout*)
      CHECKOUT_VAL=$(echo $1 | sed -e 's/^[^=]*=//g')
      if [ -n "$CHECKOUT_VAL" ]; then
        export BRANCH_NR="$CHECKOUT_VAL"
      else
      	echo "no branch number specified"
        exit 1
			fi
      ;;
		-n)
      shift
      if [ $# -gt 0 ]; then
        LIMIT=$1
      else
        echo "no limit specified"
        exit 1
      fi
      ;;
    --number*)
      LIMIT_VAL=$(echo $1 | sed -e 's/^[^=]*=//g')
      if [ -n "$LIMIT_VAL" ]; then
        LIMIT="$LIMIT_VAL"
      else
      	echo "no limit specified"
        exit 1
			fi
      ;;
    -l|--list)
      LIST=true
      ;;
    *)
      echo "-c NUMBER, --checkout=NUMBER   specify the number of the branch you want to checkout"
      echo "-h, --help                     show available options"
      echo "-l, --list                     show list of branches, without selecting one to checkout"
			echo "-n NUMBER, --number=NUMBER     specify the maximum number of branches you want to list"
      exit 0
      ;;
  esac
  shift
done

if [ "$LIST" = false ] && [ -z $BRANCH_NR ]; then
  RECENT=(
    $( \
      git reflog \
      | egrep -io 'moving from ([^[:space:]]+)' \
      | awk ' !visited[$0]++' \
      | awk '{ print $3 }' \
      | head -n $LIMIT
    )
  )

  PS3="Select branch to checkout: "
  
  select OPTION in "${RECENT[@]}"; do
    if [ -n "$OPTION" ]; then
      git checkout "$OPTION"
      break
    else
      echo "Invalid option";
    fi
  done

else
  RECENT=$( \
    git reflog \
    | egrep -io 'moving from ([^[:space:]]+)' \
    | awk ' !visited[$0]++' \
    | awk '{ print NR, "-", $3 }' \
    | head -n $LIMIT
  )

  if [ -n "$BRANCH_NR" ]; then
    BRANCH=$(grep "^$BRANCH_NR\s" <<< "$RECENT" | awk '{ print $3 }')
    git checkout "$BRANCH"

  else
    echo "$RECENT"
  fi
fi
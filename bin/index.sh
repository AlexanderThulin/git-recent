#!/bin/bash

LIMIT=10

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "-h, --help                     show available options"
      echo "-c NUMBER, --checkout=NUMBER   specify the number of the branch you want to check out"
			echo "-l NUMBER, --limit=NUMBER      specify the maximum number of branches you want to list"
      exit 0
      ;;
    -c)
      shift
      if test $# -gt 0; then
        export BRANCH_NR=$1
      else
        echo "no branch number specified"
        exit 1
      fi
      shift
      ;;
    --checkout*)
      CHECKOUT_VAL=$(echo $1 | sed -e 's/^[^=]*=//g')
      if [ -n "$CHECKOUT_VAL" ]; then
        export BRANCH_NR="$CHECKOUT_VAL"
      else
      	echo "no branch number specified"
        exit 1
			fi
      shift
      ;;
		-l)
      shift
      if test $# -gt 0; then
        LIMIT=$1
      else
        echo "no limit specified"
        exit 1
      fi
      shift
      ;;
    --limit*)
      LIMIT_VAL=$(echo $1 | sed -e 's/^[^=]*=//g')
      if [ -n "$LIMIT_VAL" ]; then
        LIMIT="$LIMIT_VAL"
      else
      	echo "no limit specified"
        exit 1
			fi
      shift
      ;;
    *)
      break
      ;;
  esac
done

RECENT=$( \
  git reflog \
  | egrep -io 'moving from ([^[:space:]]+)' \
  | awk ' !visited[$0]++' \
  | awk '{ print NR" -", $3 }' \
  | head -n $LIMIT
)

if [ -n "$BRANCH_NR" ]; then
  BRANCH=$(grep "^$BRANCH_NR\s" <<< "$RECENT" | awk '{ print $2 }')
  git checkout "$BRANCH"
else
  echo "$RECENT"
fi
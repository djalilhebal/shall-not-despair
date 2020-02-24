#!/bin/bash
##
## Since I rarely have Internet access, I needed to a script that syncs repos
##   of some interesting people like @linuxscout, @ncase, and @getify.
##
## TODO: GNU says all programs should support '--version' and '--help'
## Do as advised when [asked for code review in r/Bash](https://redd.it/b66i2k).
## TODO repo-ripper.sh --list users.txt
## TODO if repo has wiki, download it!
## TODO: Don't use GitHub API as they are limited, parse its HTML pages instead
## MAYBE: Parse options using getopts as advised?
## (sookocheff.com's "Parsing bash script options with getopts")
## MAYBE: set -euxo pipefail
## (vaneyckt.io's "Safer bash scripts with 'set -euxo pipefail'")
## TODO: add option --clean or command that runs "git gc" and whatnot
## TODO: add command "rename", as in "repo-ripper rename drama-dude dreamski21"

VERSION="v2019.08.15"

function print_help() {
  echo "Usage: repo-ripper.sh USERNAME [--include-forks | --starred]"
  echo "Downloads/Rips all of USERNAME's repos from GitHub or keeps them updated"
  echo
  echo "Example 1: repo-ripper.sh linuxscout"
  echo "syncs all of linuxscout's source repos to './ripped-repos/@linuxscout/'"
  echo "Example 2: repo-ripper.sh dreamski21 --starred"
  echo "syncs repos that are starred by dreamski21 to their owners' folders"
}

# e.g. "@dreamski21" -> "dreamski21" / "inv#l!d" -> ""
username=$(echo "$1" | tr --delete "@" | grep -oP "^[A-Za-z0-9_-]+$")

if test -z "$username"; # No (or an invalid) username was provided.
then
  print_help
  exit 1
fi

include_forks=$(test "$2" = "--include-forks" && echo "true" || echo "false")

# CONSTANTS (for the sake of clarity and readability)
API="https://api.github.com"
MAX=100 # Max entries per page, limited by GitHub
REGEX_REPO="git://github.com/(.+)/(.+)\.git" # e.g. "git://github.com/linuxscout/mishkal.git"
REGEX_REPO_NAME="[^/]+(?=\.git$)" # "(mishkal).git"
REGEX_REPO_USER="[^/]+(?=/[^/]+\.git$)" # "(linuxscout)/mishkal.git"

MY_DIR=$(dirname "$(readlink --canonicalize --no-newline "$0")")

if test "$2" = "--starred";
  then api_repos="$API/users/$username/starred?per_page=$MAX";
  else api_repos="$API/search/repositories?q=user:$username+fork:$include_forks&per_page=$MAX";
fi

page_num=1
while repos=$(wget "$api_repos&page=$page_num" -O- | grep -oP "$REGEX_REPO"); test -n "$repos"; do
  count=$(echo "$repos" | wc -l)
  echo "Page#$page_num has $count repos."

  for repo in $repos; do
    # Why lower? To correctly treat @NCase and @ncase as the same user (Linux is case-sensitive).
    repo_user=$(echo "$repo" | grep -oP "$REGEX_REPO_USER" | tr '[:upper:]' '[:lower:]')
    repo_name=$(echo "$repo" | grep -oP "$REGEX_REPO_NAME")
    user_folder="$MY_DIR/ripped-repos/@$repo_user"
    repo_folder="$user_folder/$repo_name"

    mkdir -p "$user_folder" # If the output folder doesn't exist, create it.

    echo
    echo "Doing: @$repo_user/$repo_name"
    if test -d "$repo_folder/.git/"; # If the repo was already cloned, '.git/' must've been created
      then (cd "$repo_folder" && git fetch --depth 1 && git reset --hard origin/HEAD); # Update!
      else (cd "$user_folder" && git clone --depth 1 "$repo"); # Download!
    fi
    #(cd "$user_folder/$repo_name/" && git gc --aggressive) # Clean!

  done

  if (( count < MAX )); # meaning there are no more pages/repos to fetch.
    then exit 0;
    else (( page_num++ ));
  fi

done

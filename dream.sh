#!/bin/bash

VERSION_YMD="v2020.02.24"

# The Dreamcatcher ASCII art was taken from http://ascii.co.uk/art/dreamcatcher
function print_usage() {
  echo
  echo -E "      _.---._                                                                 "
  echo -E "    .' . .'  '.    Djalil Dreamski's shitty shell scripts -- $VERSION_YMD     "
  echo -E "   /   .'. .'.'\                                                              "
  echo -E "  | \`.'  .'.'  .|  USAGE: dream.sh COMMAND [ARGS]                          "
  echo -E "  |.' '.'.' \`.' |  (it's suggested to add: alias d=\"/path/to/dream.sh\")  "
  echo -E "   \ .'.\`. .' \`/                                                            "
  echo -E "    '.'  .\`. .'                                                              "
  echo -E "      \`;---;'      COMMANDS                                                  "
  echo -E "       :   :           status : Print info about daemons (is 'panic' running?)"
  echo -E "       :   :           panic  : power-panic.sh &                              "
  echo -E "       :  /|\          loop   : links-looper.sh ARGS                          "
  echo -E "      /|\ /|\          rip    : repo-ripper.sh ARGS                           "
  echo -E "      /|\ /|\                                                                 "
  echo -E "      /|\ /|\                                                                 "
  echo -E "      /|\  '                                                                  "
  echo -E "      /|\ lc                                                                  "
  echo -E "       '                                                                      "
  echo
}

MY_DIR=$(dirname "$(readlink --canonicalize --no-newline "$0")")

args="${*:2}"

case "$1" in

  --help)
    print_usage
    ;;

  --version)
    echo "$VERSION"
    ;;

  rip)
    eval "$MY_DIR/repo-ripper.sh $args"
    ;;

  loop)
    eval "$MY_DIR/links-looper.sh $args"
    ;;

  panic)
    "$MY_DIR/power-panic.sh" &
    say "Ready to panic!"
    ;;

  status)
    answer=$(pgrep "power-panic.sh" > /dev/null && echo "Yes" || echo "No")
    echo "Is power-panic running? $answer"
    ;;

esac

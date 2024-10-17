#!/bin/sh

#########################################################################################
#                                                                                       #
# This script was auto-generated from a Justfile by just.sh.                            #
#                                                                                       #
# Generated on 2024-10-17 with just.sh version 0.0.2.                                   #
# https://github.com/jstrieb/just.sh                                                    #
#                                                                                       #
# Run `./just.sh --dump` to recover the original Justfile.                              #
#                                                                                       #
#########################################################################################

if sh "set -o pipefail" > /dev/null 2>&1; then
  set -euo pipefail
else
  set -eu
fi


#########################################################################################
# Variables                                                                             #
#########################################################################################

# User-overwritable variables (via CLI)
INVOCATION_DIRECTORY="$(pwd)"
DEFAULT_SHELL='sh'
DEFAULT_SHELL_ARGS='-cu'
LIST_HEADING='Available recipes:
'
LIST_PREFIX='    '
CHOOSER='fzf'
SORTED='true'

# Display colors
SHOW_COLOR='false'
if [ -t 1 ]; then SHOW_COLOR='true'; fi
NOCOLOR="$(test "${SHOW_COLOR}" = 'true' && printf "\033[m" || echo)"
BOLD="$(test "${SHOW_COLOR}" = 'true' && printf "\033[1m" || echo)"
RED="$(test "${SHOW_COLOR}" = 'true' && printf "\033[1m\033[31m" || echo)"
YELLOW="$(test "${SHOW_COLOR}" = 'true' && printf "\033[33m" || echo)"
CYAN="$(test "${SHOW_COLOR}" = 'true' && printf "\033[36m" || echo)"
GREEN="$(test "${SHOW_COLOR}" = 'true' && printf "\033[32m" || echo)"
PINK="$(test "${SHOW_COLOR}" = 'true' && printf "\033[35m" || echo)"
BLUE="$(test "${SHOW_COLOR}" = 'true' && printf "\033[34m" || echo)"
TICK="$(printf '%s' '`')"
DOLLAR="$(printf '%s' '$')"

assign_variables() {
  test -z "${HAS_RUN_assign_variables:-}" || return 0

  # No user-declared variables

  HAS_RUN_assign_variables="true"
}


#########################################################################################
# Recipes                                                                               #
#########################################################################################

FUN_run() {
  # Recipe setup and pre-recipe dependencies
  test -z "${HAS_RUN_run:-}" \
    || test "${FORCE_run:-}" = "true" \
    || return 0

  OLD_WD="$(pwd)"
  cd "${INVOCATION_DIRECTORY}"

  # Recipe body
  echo_recipe_line 'v run ./src'
  env "${DEFAULT_SHELL}" ${DEFAULT_SHELL_ARGS} \
    'v run ./src'  \
    || recipe_error "run" "${LINENO:-}"

  # Post-recipe dependencies and teardown
  cd "${OLD_WD}"
  if [ -z "${FORCE_run:-}" ]; then
    HAS_RUN_run="true"
  fi
}

FUN_deploy() {
  # Recipe setup and pre-recipe dependencies
  test -z "${HAS_RUN_deploy:-}" \
    || test "${FORCE_deploy:-}" = "true" \
    || return 0

  if [ "${FORCE_deploy:-}" = "true" ]; then
    FORCE_compile_blogs="true"
  fi
  FUN_compile_blogs
  if [ "${FORCE_deploy:-}" = "true" ]; then
    FORCE_compile_blogs=
  fi
  if [ "${FORCE_deploy:-}" = "true" ]; then
    FORCE_compile="true"
  fi
  FUN_compile
  if [ "${FORCE_deploy:-}" = "true" ]; then
    FORCE_compile=
  fi
  if [ "${FORCE_deploy:-}" = "true" ]; then
    FORCE_transfer_to_server="true"
  fi
  FUN_transfer_to_server
  if [ "${FORCE_deploy:-}" = "true" ]; then
    FORCE_transfer_to_server=
  fi

  OLD_WD="$(pwd)"
  cd "${INVOCATION_DIRECTORY}"

  # Recipe body


  # Post-recipe dependencies and teardown
  cd "${OLD_WD}"
  if [ -z "${FORCE_deploy:-}" ]; then
    HAS_RUN_deploy="true"
  fi
}

FUN_compile() {
  # Recipe setup and pre-recipe dependencies
  test -z "${HAS_RUN_compile:-}" \
    || test "${FORCE_compile:-}" = "true" \
    || return 0

  OLD_WD="$(pwd)"
  cd "${INVOCATION_DIRECTORY}"

  # Recipe body
  echo_recipe_line 'v ./src -o website.bin -prod'
  env "${DEFAULT_SHELL}" ${DEFAULT_SHELL_ARGS} \
    'v ./src -o website.bin -prod'  \
    || recipe_error "compile" "${LINENO:-}"

  # Post-recipe dependencies and teardown
  cd "${OLD_WD}"
  if [ -z "${FORCE_compile:-}" ]; then
    HAS_RUN_compile="true"
  fi
}

FUN_compile_blogs() {
  # Recipe setup and pre-recipe dependencies
  test -z "${HAS_RUN_compile_blogs:-}" \
    || test "${FORCE_compile_blogs:-}" = "true" \
    || return 0

  OLD_WD="$(pwd)"
  cd "${INVOCATION_DIRECTORY}"

  # Recipe body
  echo_recipe_line 'v run compile_blogs.v'
  env "${DEFAULT_SHELL}" ${DEFAULT_SHELL_ARGS} \
    'v run compile_blogs.v'  \
    || recipe_error "compile-blogs" "${LINENO:-}"

  # Post-recipe dependencies and teardown
  cd "${OLD_WD}"
  if [ -z "${FORCE_compile_blogs:-}" ]; then
    HAS_RUN_compile_blogs="true"
  fi
}

FUN_transfer_to_server() {
  # Recipe setup and pre-recipe dependencies
  test -z "${HAS_RUN_transfer_to_server:-}" \
    || test "${FORCE_transfer_to_server:-}" = "true" \
    || return 0

  OLD_WD="$(pwd)"
  cd "${INVOCATION_DIRECTORY}"

  # Recipe body
  echo_recipe_line 'scp -r ./blog/ tauraamui@tauraamui.website:~/'
  env "${DEFAULT_SHELL}" ${DEFAULT_SHELL_ARGS} \
    'scp -r ./blog/ tauraamui@tauraamui.website:~/'  \
    || recipe_error "transfer-to-server" "${LINENO:-}"
  echo_recipe_line 'scp ./website.bin tauraamui@tauraamui.website:~/'
  env "${DEFAULT_SHELL}" ${DEFAULT_SHELL_ARGS} \
    'scp ./website.bin tauraamui@tauraamui.website:~/'  \
    || recipe_error "transfer-to-server" "${LINENO:-}"

  # Post-recipe dependencies and teardown
  cd "${OLD_WD}"
  if [ -z "${FORCE_transfer_to_server:-}" ]; then
    HAS_RUN_transfer_to_server="true"
  fi
}

FUN_run_watch() {
  # Recipe setup and pre-recipe dependencies
  test -z "${HAS_RUN_run_watch:-}" \
    || test "${FORCE_run_watch:-}" = "true" \
    || return 0

  OLD_WD="$(pwd)"
  cd "${INVOCATION_DIRECTORY}"

  # Recipe body
  echo_recipe_line 'v -d vweb_livereload watch run .'
  env "${DEFAULT_SHELL}" ${DEFAULT_SHELL_ARGS} \
    'v -d vweb_livereload watch run .'  \
    || recipe_error "run-watch" "${LINENO:-}"

  # Post-recipe dependencies and teardown
  cd "${OLD_WD}"
  if [ -z "${FORCE_run_watch:-}" ]; then
    HAS_RUN_run_watch="true"
  fi
}

FUN_install_deps() {
  # Recipe setup and pre-recipe dependencies
  test -z "${HAS_RUN_install_deps:-}" \
    || test "${FORCE_install_deps:-}" = "true" \
    || return 0

  OLD_WD="$(pwd)"
  cd "${INVOCATION_DIRECTORY}"

  # Recipe body
  echo_recipe_line 'pnpm install -S hackcss-ext'
  env "${DEFAULT_SHELL}" ${DEFAULT_SHELL_ARGS} \
    'pnpm install -S hackcss-ext'  \
    || recipe_error "install-deps" "${LINENO:-}"
  echo_recipe_line 'v install markdown'
  env "${DEFAULT_SHELL}" ${DEFAULT_SHELL_ARGS} \
    'v install markdown'  \
    || recipe_error "install-deps" "${LINENO:-}"

  # Post-recipe dependencies and teardown
  cd "${OLD_WD}"
  if [ -z "${FORCE_install_deps:-}" ]; then
    HAS_RUN_install_deps="true"
  fi
}


#########################################################################################
# Helper functions                                                                      #
#########################################################################################

# Sane, portable echo that doesn't escape characters like "\n" behind your back
echo() {
  if [ "${#}" -gt 0 ]; then
    printf "%s\n" "${@}"
  else
    printf "\n"
  fi
}

# realpath is a GNU coreutils extension
realpath() {
  # The methods to replicate it get increasingly error-prone
  # TODO: improve
  if type -P realpath > /dev/null 2>&1; then
    "$(type -P realpath)" "${1}"
  elif type python3 > /dev/null 2>&1; then
    python3 -c 'import os.path, sys; print(os.path.realpath(sys.argv[1]))' "${1}"
  elif type python > /dev/null 2>&1; then
    python -c 'import os.path, sys; print os.path.realpath(sys.argv[1])' "${1}"
  elif [ -f "${1}" ] && ! [ -z "$(dirname "${1}")" ]; then
    # We assume the directory exists. For our uses, it always does
    echo "$(
      cd "$(dirname "${1}")";
      pwd -P
    )/$(
      basename "${1}"
    )"
  elif [ -f "${1}" ]; then
    pwd -P
  elif [ -d "${1}" ]; then
  (
    cd "${1}"
    pwd -P
  )
  else
    echo "${1}"
  fi
}

echo_error() {
  echo "${RED}error${NOCOLOR}: ${BOLD}${1}${NOCOLOR}" >&2
}

recipe_error() {
  STATUS="${?}"
  if [ -z "${2:-}" ]; then
      echo_error "Recipe "'`'"${1}"'`'" failed with exit code ${STATUS}"
  else
      echo_error "Recipe "'`'"${1}"'`'" failed on line ${2} with exit code ${STATUS}"
  fi
  exit "${STATUS}"
}

echo_recipe_line() {
  echo "${BOLD}${1}${NOCOLOR}" >&2
}
            
set_var() {
  export "VAR_${1}=${2}"
}
            
summarizefn() {
  while [ "$#" -gt 0 ]; do
    case "${1}" in
    -u|--unsorted)
      SORTED="false"
      ;;
    esac
    shift
  done

  if [ "${SORTED}" = "true" ]; then
    printf "%s " compile compile-blogs deploy install-deps run run-watch transfer-to-server
  else
    printf "%s " run deploy compile compile-blogs transfer-to-server run-watch install-deps
  fi
  echo

}

usage() {
  cat <<EOF
${GREEN}just.sh${NOCOLOR} 0.0.2
Jacob Strieb
    Auto-generated from a Justfile by just.sh - https://github.com/jstrieb/just.sh

${YELLOW}USAGE:${NOCOLOR}
    ./just.sh [FLAGS] [OPTIONS] [ARGUMENTS]...

${YELLOW}FLAGS:${NOCOLOR}
        ${GREEN}--choose${NOCOLOR}      Select one or more recipes to run using a binary. If ${TICK}--chooser${TICK} is not passed the chooser defaults to the value of ${DOLLAR}JUST_CHOOSER, falling back to ${TICK}fzf${TICK}
        ${GREEN}--dump${NOCOLOR}        Print justfile
        ${GREEN}--evaluate${NOCOLOR}    Evaluate and print all variables. If a variable name is given as an argument, only print that variable's value.
        ${GREEN}--init${NOCOLOR}        Initialize new justfile in project root
    ${GREEN}-l, --list${NOCOLOR}        List available recipes and their arguments
        ${GREEN}--summary${NOCOLOR}     List names of available recipes
    ${GREEN}-u, --unsorted${NOCOLOR}    Return list and summary entries in source order
    ${GREEN}-h, --help${NOCOLOR}        Print help information
    ${GREEN}-V, --version${NOCOLOR}     Print version information

${YELLOW}OPTIONS:${NOCOLOR}
        ${GREEN}--chooser <CHOOSER>${NOCOLOR}           Override binary invoked by ${TICK}--choose${TICK}
        ${GREEN}--list-heading <TEXT>${NOCOLOR}         Print <TEXT> before list
        ${GREEN}--list-prefix <TEXT>${NOCOLOR}          Print <TEXT> before each list item
        ${GREEN}--set <VARIABLE> <VALUE>${NOCOLOR}      Override <VARIABLE> with <VALUE>
        ${GREEN}--shell <SHELL>${NOCOLOR}               Invoke <SHELL> to run recipes
        ${GREEN}--shell-arg <SHELL-ARG>${NOCOLOR}       Invoke shell with <SHELL-ARG> as an argument

${YELLOW}ARGS:${NOCOLOR}
    ${GREEN}<ARGUMENTS>...${NOCOLOR}    Overrides and recipe(s) to run, defaulting to the first recipe in the justfile
EOF
}

err_usage() {
  cat <<EOF >&2
USAGE:
    ./just.sh [FLAGS] [OPTIONS] [ARGUMENTS]...

For more information try ${GREEN}--help${NOCOLOR}
EOF
}

listfn() {
  while [ "$#" -gt 0 ]; do
    case "${1}" in
    --list-heading)
      shift
      LIST_HEADING="${1}"
      ;;

    --list-prefix)
      shift
      LIST_PREFIX="${1}"
      ;;

    -u|--unsorted)
      SORTED="false"
      ;;
    esac
    shift
  done

  printf "%s" "${LIST_HEADING}"
  if [ "${SORTED}" = "true" ]; then 
    echo "${LIST_PREFIX}"'compile'"${BLUE}""${NOCOLOR}"
    echo "${LIST_PREFIX}"'compile-blogs'"${BLUE}""${NOCOLOR}"
    echo "${LIST_PREFIX}"'deploy'"${BLUE}""${NOCOLOR}"
    echo "${LIST_PREFIX}"'install-deps'"${BLUE}""${NOCOLOR}"
    echo "${LIST_PREFIX}"'run'"${BLUE}""${NOCOLOR}"
    echo "${LIST_PREFIX}"'run-watch'"${BLUE}""${NOCOLOR}"
    echo "${LIST_PREFIX}"'transfer-to-server'"${BLUE}""${NOCOLOR}"
  else
    echo "${LIST_PREFIX}"'run'"${BLUE}""${NOCOLOR}"
    echo "${LIST_PREFIX}"'deploy'"${BLUE}""${NOCOLOR}"
    echo "${LIST_PREFIX}"'compile'"${BLUE}""${NOCOLOR}"
    echo "${LIST_PREFIX}"'compile-blogs'"${BLUE}""${NOCOLOR}"
    echo "${LIST_PREFIX}"'transfer-to-server'"${BLUE}""${NOCOLOR}"
    echo "${LIST_PREFIX}"'run-watch'"${BLUE}""${NOCOLOR}"
    echo "${LIST_PREFIX}"'install-deps'"${BLUE}""${NOCOLOR}"
  fi
}

dumpfn() {
  cat <<"8c74644b4eb9b0d0"
run:
    v run ./src

deploy: compile-blogs compile transfer-to-server

compile:
    v ./src -o website.bin -prod

compile-blogs:
    v run compile_blogs.v

transfer-to-server:
    scp -r ./blog/ tauraamui@tauraamui.website:~/
    scp ./website.bin tauraamui@tauraamui.website:~/

run-watch:
    v -d vweb_livereload watch run .

install-deps:
    pnpm install -S hackcss-ext
    v install markdown
8c74644b4eb9b0d0
}

evaluatefn() {
  assign_variables || exit "${?}"
  if [ "${#}" = "0" ]; then
    true
  else
    case "${1}" in
    # No user-declared variables
    *)
      echo_error 'Justfile does not contain variable `'"${1}"'`.'
      exit 1
      ;;
    esac
  fi
}

choosefn() {
  echo 'run' 'deploy' 'compile' 'compile-blogs' 'transfer-to-server' 'run-watch' 'install-deps' \
    | "${DEFAULT_SHELL}" ${DEFAULT_SHELL_ARGS} "${CHOOSER}"
}


#########################################################################################
# Main entrypoint                                                                       #
#########################################################################################

RUN_DEFAULT='true'
while [ "${#}" -gt 0 ]; do
  case "${1}" in 
  
  # User-defined recipes
  run)
    shift
    assign_variables || exit "${?}"
    FUN_run "$@"
    RUN_DEFAULT='false'
    ;;

  deploy)
    shift
    assign_variables || exit "${?}"
    FUN_deploy "$@"
    RUN_DEFAULT='false'
    ;;

  compile)
    shift
    assign_variables || exit "${?}"
    FUN_compile "$@"
    RUN_DEFAULT='false'
    ;;

  compile-blogs)
    shift
    assign_variables || exit "${?}"
    FUN_compile_blogs "$@"
    RUN_DEFAULT='false'
    ;;

  transfer-to-server)
    shift
    assign_variables || exit "${?}"
    FUN_transfer_to_server "$@"
    RUN_DEFAULT='false'
    ;;

  run-watch)
    shift
    assign_variables || exit "${?}"
    FUN_run_watch "$@"
    RUN_DEFAULT='false'
    ;;

  install-deps)
    shift
    assign_variables || exit "${?}"
    FUN_install_deps "$@"
    RUN_DEFAULT='false'
    ;;
  
  # Built-in flags
  -l|--list)
    shift 
    listfn "$@"
    RUN_DEFAULT="false"
    break
    ;;
    
  -f|--justfile)
    shift 2
    echo "${YELLOW}warning${NOCOLOR}: ${BOLD}-f/--justfile not implemented by just.sh${NOCOLOR}" >&2
    ;;

  --summary)
    shift
    summarizefn "$@"
    RUN_DEFAULT="false"
    break
    ;;

  --list-heading)
    shift
    LIST_HEADING="${1}"
    shift
    ;;

  --list-prefix)
    shift
    LIST_PREFIX="${1}"
    shift
    ;;

  -u|--unsorted)
    SORTED="false"
    shift
    ;;

  --shell)
    shift
    DEFAULT_SHELL="${1}"
    shift
    ;;

  --shell-arg)
    shift
    DEFAULT_SHELL_ARGS="${1}"
    shift
    ;;
    
  -V|--version)
    shift
    echo "just.sh 0.0.2"
    echo
    echo "https://github.com/jstrieb/just.sh"
    RUN_DEFAULT="false"
    break
    ;;

  -h|--help)
    shift
    usage
    RUN_DEFAULT="false"
    break
    ;;

  --choose)
    shift
    assign_variables || exit "${?}"
    TARGET="$(choosefn)"
    env "${0}" "${TARGET}" "$@"
    RUN_DEFAULT="false"
    break
    ;;
    
  --chooser)
    shift
    CHOOSER="${1}"
    shift
    ;;
    
  *=*)
    assign_variables || exit "${?}"
    NAME="$(
        echo "${1}" | tr '\n' '\r' | sed 's/\([^=]*\)=.*/\1/g' | tr '\r' '\n'
    )"
    VALUE="$(
        echo "${1}" | tr '\n' '\r' | sed 's/[^=]*=\(.*\)/\1/g' | tr '\r' '\n'
    )"
    shift
    set_var "${NAME}" "${VALUE}"
    ;;

  --set)
    shift
    assign_variables || exit "${?}"
    NAME="${1}"
    shift
    VALUE="${1}"
    shift
    set_var "${NAME}" "${VALUE}"
    ;;
    
  --dump)
    RUN_DEFAULT="false"
    dumpfn "$@"
    break
    ;;
    
  --evaluate)
    shift
    RUN_DEFAULT="false"
    evaluatefn "$@"
    break
    ;;
    
  --init)
    shift
    RUN_DEFAULT="false"
    if [ -f "justfile" ]; then
      echo_error "Justfile "'`'"$(realpath "justfile")"'`'" already exists"
      exit 1
    fi
    cat > "justfile" <<EOF
default:
    echo 'Hello, world!'
EOF
    echo 'Wrote justfile to `'"$(realpath "justfile")"'`' 2>&1 
    break
    ;;

  -*)
    echo_error "Found argument '${NOCOLOR}${YELLOW}${1}${NOCOLOR}${BOLD}' that wasn't expected, or isn't valid in this context"
    echo >&2
    err_usage
    exit 1
    ;;

  *)
    assign_variables || exit "${?}"
    echo_error 'Justfile does not contain recipe `'"${1}"'`.'
    exit 1
    ;;
  esac
done

if [ "${RUN_DEFAULT}" = "true" ]; then
  assign_variables || exit "${?}"
  FUN_run "$@" 
fi


#########################################################################################
#                                                                                       #
# This script was auto-generated from a Justfile by just.sh.                            #
#                                                                                       #
# Generated on 2024-10-17 with just.sh version 0.0.2.                                   #
# https://github.com/jstrieb/just.sh                                                    #
#                                                                                       #
# Run `./just.sh --dump` to recover the original Justfile.                              #
#                                                                                       #
#########################################################################################


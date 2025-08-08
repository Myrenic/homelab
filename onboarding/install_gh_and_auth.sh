#!/bin/bash
set -e
trap 'tput cnorm; echo; exit' INT TERM

if [[ -z "$BASH_VERSION" ]]; then
  echo "This script must be run with bash"
  exit 1
fi

# Define colors
PURPLE='\e[35m'
BLUE='\e[94m'
RED='\e[91m'
GREEN='\e[92m'
RESET='\e[0m'

# Print colored text without newline
print_color() {
  local color=$1
  local text=$2
  echo -ne "${color}${text}${RESET}"
}

# Print ASCII banner
print_banner() {
  cat <<'EOF'
                                                          *%###%###%
                                                     ,%.    ./&&&  ,#,
                                                  ,             &&&.
                 ,###%#            *####%    ##%###############*#&&@
                ########         .%######,,#################### &&&,
               %#########       #########(        #####(       &&&(
              ##### /#####    ##### .####%       /#####      %&&&.
            .#####   (##### #####,   #####       #####(    /&&&&
           /#####     %########/     #####*     ,#####   %&&&&
          ######       ######%       #####%     ####( /&&&&&
                         ..                       .&&&&&&.
                                     *&&&&#(#&&&&&&&&&
                                      #&&&&&&&&&&%
EOF
  echo -e "Myrenic's GitHub CLI Auth Script\n"
}

# Loading animation
loading_animation() {
  local pid=$1
  local frames=("▁" "▃" "▄" "▅" "▆" "▇" "█" "▇" "▆" "▅" "▄" "▃")
  local delay=0.1
  local i=0

  tput civis
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r${BLUE}[.]  Installing GitHub CLI .... [%s]${RESET}" "${frames[i]}"
    i=$(( (i + 1) % ${#frames[@]} ))
    sleep "$delay"
  done
  printf "\r${BLUE}[x]  Installed GitHub CLI${RESET}\n"
  tput cnorm
}

# Prompt for GitHub token and validate it
prompt_for_token() {
  print_color "$RESET" "\n    Please create a personal access token with scopes:\n"
  print_color "$RESET" "    repo, workflow, gist, read:org\n"
  print_color "$RED" "\n    https://github.com/settings/tokens/new\n\n"
  read -s -p "[?] Enter your personal access token: " TOKEN
  echo
  if [[ -z "$TOKEN" ]]; then
    echo -e "\n${RED}Token cannot be empty. Exiting.${RESET}"
    exit 1
  fi
  if [[ ! "$TOKEN" =~ ^ghp_[A-Za-z0-9]{36}$ ]]; then
    echo -e "\n${RED}[!]  Invalid GitHub token format. Exiting.${RESET}"
    exit 1
  fi

  if echo "$TOKEN" | gh auth login --with-token > /dev/null 2>&1; then
    unset TOKEN
  else
    unset TOKEN
    echo -e "\n${RED}[!] Failed to authenticate to GitHub. Invalid token.${RESET}"
    exit 1
  fi

  if gh auth status &> /dev/null; then
    echo -e "\n${GREEN}[x] Successfully authenticated to GitHub.${RESET}"
  else
    echo -e "\n${RED}[!] Failed to authenticate to GitHub. Invalid token.${RESET}"
    exit 1
  fi
}

# --- Script Starts ---

print_banner

# Install GitHub CLI if not present
if ! command -v gh &>/dev/null; then
  print_color "$BLUE" "[!]  GitHub CLI not found. Installing...\n"
  {
    sudo apt update &> /dev/null
    sudo apt install -y gh &> /dev/null
  } &
  loading_animation $!
else
  print_color "$GREEN" "[x] GitHub CLI is already installed.\n"
fi

# Check authentication status
auth_status=$(gh auth status 2>&1 || true)
if [[ "$auth_status" == *"Logged in to"* ]]; then
  username=$(echo "$auth_status" | grep -oP 'account \K\S+')
  print_color "$GREEN" "[!] You are already authenticated. ($username)\n"
  read -p "[?] Do you want to log out and log in with a different user? (y/n): " choice
  if [[ "$choice" =~ ^[yY]$ ]]; then
    gh auth logout &> /dev/null
    prompt_for_token
  else
    print_color "$GREEN" "\nContinuing with the current user.\n"
  fi
else
  print_color "$RESET" "[!] Github CLI not yet authenticated"
  prompt_for_token
fi

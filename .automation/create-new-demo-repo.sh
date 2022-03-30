#!/bin/bash

################################################################################
# VARS 
#   Please reference for GitHub environment varaiables:
#      https://docs.github.com/en/actions/reference/environment-variables 
################################################################################

################################################################################
#### Function PrintUsage #######################################################
PrintUsage() {
  cat <<EOM
Usage: create-new-demo-repo.sh [options]

Options:
    -h, --help                    : Show script help
    -d, --Debug                   : Enable Debug logging
    -t, --token                   : Set Personal Access Token with repo scope - Looks for GITHUB_TOKEN environment
                                    variable if omitted
    -o, --organization            : Name of the GitHub organization to create repo
    -r, --repo                    : Name of the GitHub repo to create

Description:
create-new-demo-repo.sh creates a demo repo in an organization to give the GitHub Actions training course

Example:
  ./create-new-demo-repo.sh -t ABCDEFG1234567 -o myOrg -r demo-actions-1

EOM
  exit 0
}
####################################
# Read in the parameters if passed #
####################################
PARAMS=""
while (( "$#" )); do
  case "$1" in
    -h|--help)
      PrintUsage;
      ;;
    -d|--DEBUG)
      DEBUG=true
      shift
      ;;
    -t|--token)
      GITHUB_TOKEN=$2
      shift 2
      ;;
    -o|--organization)
      ORG_NAME=$2
      shift 2
      ;;
    -r|--repo)
      REPO_NAME=$2
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
  PARAMS="$PARAMS $1"
  shift
  ;;
  esac
done

##################################################
# Set positional arguments in their proper place #
##################################################
eval set -- "$PARAMS"

###########
# GLOBALS #
###########
GITHUB_TOKEN="${GITHUB_TOKEN}"   # GitHub Token passed from environment
GITHUB_API="https://api.github.com" # GitHub API URL
SOURCE_DEMO_REPO="https://github.com/githubtraining/GitHub-Actions-Docker-training" # Repo to clone

################################################################################
########################## FUNCTIONS BELOW #####################################
################################################################################
################################################################################
#### Function Debug ############################################################
Debug() {
  # If Debug is on, print it out...
  if [[ ${DEBUG} == true ]]; then
    echo "$1"
  fi
}
################################################################################
#### Function Header ###########################################################
Header() {
  echo "----------------------------------"
  echo "--- Demo Repo Creation Script ----"
  echo "----------------------------------"
  echo ""
}
################################################################################
#### Function ValidateToken ####################################################
ValidateToken() {
  if [ -z "${GITHUB_TOKEN}" ]; then
    echo "----------------------------------"
    echo "GH_TOKEN not found in environment."
    echo "Please enter your GitHub Personal Access Token"
    echo "Followed by [ENTER]"
    echo "Note: your token will not be displayed"
    read -s -r GITHUB_TOKEN

    if [ "${#GITHUB_TOKEN}" -ne 40 ]; then
      echo "----------------------------------"
      echo "GH_TOKENs are 40 chars in length!"
      echo "we recieved ${#GITHUB_TOKEN} chars"
      exit 1
    fi
  fi

  echo "----------------------------------"
  echo "Validating GH_TOKEN..."

  ###################################################
  # Run command to validate token and get user name #
  ###################################################
  GET_USER_NAME_CMD=$(curl --fail -s \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    "${GITHUB_API}/user" \
    | jq -r .login 2>&1
  )

  Debug "DEBUG: GET_USER_NAME_CMD:[${GET_USER_NAME_CMD}]"
  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ########################
  # Check the error code #
  ########################
  if [ "${ERROR_CODE}" -ne 0 ]; then
    echo "----------------------------------"
    echo "Error: ${ERROR_CODE}"
    echo "Failed to validate user token."
    echo "ERROR:[${GET_USER_NAME_CMD}]"
    echo "----------------------------------"
    exit 1
  else
    echo "Validation successful"
    echo "User:[${GET_USER_NAME_CMD}]"
  fi
}
################################################################################
#### Function ValidateInput ####################################################
ValidateInput() {

  ##############################################################
  # Check if user passed in an organization name and repo name #
  ##############################################################
  if [ -z "${ORG_NAME}" ] || [ -z "${REPO_NAME}" ]; then
    echo "----------------------------------"
    echo "Error: Organization and Repo names are required"
    echo "Please use the --organization and --repo flags with the correct values"
    echo "----------------------------------"
    exit 1
  fi

  echo "----------------------------------"
  echo "Checking if repo name is valid..."

  ###################
  # Get users repos #
  ###################
  GET_REPO_CMD=$(curl -s -o /dev/null -I -w "%{http_code}" -X GET \
    --url "${GITHUB_API}/repos/${ORG_NAME}/${REPO_NAME}" \
    -H 'Accept: application/vnd.github.nebula-preview+json' \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H 'Content-Type: application/json' 2>&1
  )

  Debug "DEBUG: GET_REPO_CMD:[${GET_REPO_CMD}]"
  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ########################
  # Check the error code #
  ########################
  if [ "${ERROR_CODE}" -eq 0 ] && [ "${GET_REPO_CMD}" -eq 404 ]; then
    echo "----------------------------------"
    echo "Repo name does not exist, were good to create it..."
    echo "----------------------------------"
  else
    echo "----------------------------------"
    echo "Error: ${ERROR_CODE}"
    echo "Failed to validate repo name, or the repo already exists!"
    echo "ERROR:[${GET_REPO_CMD}]"
    echo "----------------------------------"
    exit 1
  fi
}
################################################################################
#### Function CloneLocalRepo ###################################################
CloneLocalRepo() {
  echo "----------------------------------"
  echo "Cloning local repo..."

  ##################################
  # Clone the local repo to a temp #
  ##################################
  CLONE_CMD=$(
    mkdir "/tmp/${REPO_NAME}" || exit 1
    git clone "${SOURCE_DEMO_REPO}" "/tmp/${REPO_NAME}" 2>&1
  )

  Debug "DEBUG: CLONE_CMD:[${CLONE_CMD}]"
  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ########################
  # Check the error code #
  ########################
  if [ "${ERROR_CODE}" -ne 0 ]; then
    echo "----------------------------------"
    echo "Error: ${ERROR_CODE}"
    echo "Failed to clone local repo."
    echo "ERROR:[${CLONE_CMD}]"
    echo "----------------------------------"
    exit 1
  else
    echo "Cloning successful to:[/tmp/${REPO_NAME}]"
  fi
}
################################################################################
#### Function CreateEmptyRepo ##################################################
CreateEmptyRepo() {
  echo "----------------------------------"
  echo "Creating uninitialized repository:[${ORG_NAME}/${REPO_NAME}] on GitHub..."

  CREATE_CMD=$(curl --fail -s -X POST \
    --url "${GITHUB_API}/orgs/${ORG_NAME}/repos" \
    -H 'Accept: application/vnd.github.nebula-preview+json' \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H 'Content-Type: application/json' \
    -d '{
      "name": "'"${REPO_NAME}"'",
      "description": "Demo Actions Repo",
      "homepage": "https://github.com",
      "private": false,
      "has_issues": true,
      "auto_init": false
    }' 2>&1
  )
  
  Debug "DEBUG: CREATE_CMD:[${CREATE_CMD}]"
  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ########################
  # Check the error code #
  ########################
  if [ "${ERROR_CODE}" -ne 0 ]; then
    echo "----------------------------------"
    echo "Error: ${ERROR_CODE}"
    echo "Failed to create repo!"
    echo "ERROR:[${CREATE_CMD}]"
    echo "----------------------------------"
    exit 1
  else
    echo "Successful created repo:[${ORG_NAME}/${REPO_NAME}]"
  fi
}
################################################################################
#### Function PushLocalRepo ####################################################
PushLocalRepo() {

  # Check the user has git configured with user.name and user.email
  VALIDATE_GIT_USER_CMD=$(git config --global --get user.name 2>&1)

  Debug "DEBUG: VALIDATE_GIT_USER_CMD:[${VALIDATE_GIT_USER_CMD}]"
  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ########################
  # Check the error code #
  ########################
  if [ "${ERROR_CODE}" -ne 0 ]; then
    echo "----------------------------------"
    echo "Error: ${ERROR_CODE}"
    echo "Failed to validate user.name!"
    echo "Please set user.name and user.email in your git config"
    echo "Example: git config --global user.name \"John Doe\""
    echo "ERROR:[${VALIDATE_GIT_USER_CMD}]"
    echo "----------------------------------"
    exit 1
  else
    echo "git user.name is set"
  fi

  # Check the user has git configured with user.name and user.email
  VALIDATE_GIT_USER_CMD=$(git config --global --get user.email 2>&1)

  Debug "DEBUG: VALIDATE_GIT_USER_CMD:[${VALIDATE_GIT_USER_CMD}]"
  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ########################
  # Check the error code #
  ########################
  if [ "${ERROR_CODE}" -ne 0 ]; then
    echo "----------------------------------"
    echo "Error: ${ERROR_CODE}"
    echo "Failed to validate user.email!"
    echo "Please set user.name and user.email in your git config"
    echo "Example: git config --global user.email \"John.Doe@github.com\""
    echo "ERROR:[${VALIDATE_GIT_USER_CMD}]"
    echo "----------------------------------"
    exit 1
  else
    echo "git user.email is set"
  fi

  # Update the local repo with the new remote
  echo "----------------------------------"
  echo "Updating local repo with new remote..."

  # Update the local repo with the new remote
  UPDATE_CMD=$(
    cd "/tmp/${REPO_NAME}" || exit 1
    git remote rm origin || exit 1
    git remote add origin "https://github.com/${ORG_NAME}/${REPO_NAME}.git" || exit 1
    2>&1
  )

  Debug "DEBUG: UPDATE_CMD:[${UPDATE_CMD}]"
  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ########################
  # Check the error code #
  ########################
  if [ "${ERROR_CODE}" -ne 0 ]; then
    echo "----------------------------------"
    echo "Error: ${ERROR_CODE}"
    echo "Failed to update repo origin!"
    echo "ERROR:[${UPDATE_CMD}]"
    echo "----------------------------------"
    exit 1
  else
    echo "Successful updated repo origin"
  fi

  #################################
  # Push the local repo to GitHub #
  #################################
  echo "----------------------------------"
  echo "Pushing local repo to GitHub..."
  PUSH_CMD=$(
    cd "/tmp/${REPO_NAME}" || exit 1
    git push origin main || exit 1 2>&1
  )

  Debug "DEBUG: PUSH_CMD:[${PUSH_CMD}]"
  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ########################
  # Check the error code #
  ########################
  if [ "${ERROR_CODE}" -ne 0 ]; then
    echo "----------------------------------"
    echo "Error: ${ERROR_CODE}"
    echo "Failed to push repo to origin!"
    echo "ERROR:[${PUSH_CMD}]"
    echo "----------------------------------"
    exit 1
  else
    echo "Successful pushed repo to origin"
  fi

  ###############################
  # Remove the local repository #
  ###############################
  REMOVE_CMD=$(
    rm -rf "/tmp/${REPO_NAME}" || exit 1
  )

  Debug "DEBUG: REMOVE_CMD:[${REMOVE_CMD}]"
  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ########################
  # Check the error code #
  ########################
  if [ "${ERROR_CODE}" -ne 0 ]; then
    echo "----------------------------------"
    echo "Error: ${ERROR_CODE}"
    echo "Failed to remove local repo!"
    echo "ERROR:[${REMOVE_CMD}]"
    echo "----------------------------------"
    exit 1
  else
    echo "Successful removed the local repo"
  fi
}
################################################################################
#### Function ValidateJQ #######################################################
ValidateJQ() {
  # Need to validate the machine has jq installed as we use it to do the parsing
  # of all the json returns from GitHub

  if ! jq --version &>/dev/null
  then
    echo "Failed to find jq in the path!"
    echo "If this is a Mac, run command: brew install jq"
    echo "If this is Debian, run command: sudo apt install jq"
    echo "If this is Centos, run command: yum install jq"
    echo "Once installed, please run this script again."
    exit 1
  fi
}
################################################################################
#### Function Footer ###########################################################
Footer() {
  echo "----------------------------------"
  echo "Successfully created demo repository!"
  echo "https://github.com/${ORG_NAME}/${REPO_NAME}"
  echo "----------------------------------"
}
################################################################################
############################### MAIN ###########################################
################################################################################

##########
# Header #
##########
Header

#########################
# Print if debug is set #
#########################
Debug "DEBUG: GITHUB_TOKEN:[${GITHUB_TOKEN}]"
Debug "DEBUG: GITHUB_API:[${GITHUB_API}]"
Debug "DEBUG: SOURCE_DEMO_REPO:[${SOURCE_DEMO_REPO}]"
Debug "DEBUG: ORG_NAME:[${ORG_NAME}]"
Debug "DEBUG: REPO_NAME:[${REPO_NAME}]"

#########################
# Validate JQ installed #
#########################
ValidateJQ

##################
# Validate token #
##################
ValidateToken

#################################
# Check we have an org and repo #
#################################
ValidateInput

##########################
# Clone the repo locally #
##########################
CloneLocalRepo

#####################
# Create empty repo #
#####################
CreateEmptyRepo

#############################
# Push local repo to GitHub #
#############################
PushLocalRepo

##########
# Footer #
##########
Footer
function ask {

    local QUESTION="$1"
    local DEFAULT_ANSWER="$2"

    local PROMPT="$QUESTION"

    read -e -p "${PROMPT}: " -i "$DEFAULT_ANSWER" USER_ANSWER
    echo $USER_ANSWER
}

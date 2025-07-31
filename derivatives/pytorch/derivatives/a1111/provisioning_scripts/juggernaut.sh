#!/bin/bash

#########################   TEMPLATE POUR JUGGERNAUTXL #########################

source /venv/main/bin/activate
A1111_DIR=${WORKSPACE}/stable-diffusion-webui

# Packages are installed after nodes so we can fix them...

APT_PACKAGES=(
    #"package-1"
    #"package-2"
)

PIP_PACKAGES=(

)

CHECKPOINT_MODELS=(
    # JuggernautXL
    "JuggernautXL.safetensors;https://civitai.com/api/download/models/1759168?type=Model&format=SafeTensor&size=full&fp=fp16"
    # Babes By Stable Yogi
    "BabesYogi.safetensors;https://civitai.com/api/download/models/1075493?type=Model&format=SafeTensor&size=pruned&fp=fp16"
)

UNET_MODELS=(

)

LORA_MODELS=(
    # AmateurTriggerXL
    "AmateurTriggerXL.safetensors;https://civitai.com/api/download/models/1835441?type=Model&format=SafeTensor"
    # Puffies
    "Puffies.safetensors;https://civitai.com/api/download/models/1876756?type=Model&format=SafeTensor"
    # SimpsPussy
    "SimpsPussy.safetensors;https://civitai.com/api/download/models/1841736?type=Model&format=SafeTensor"
    # BetterHands
    "BetterHands.safetensors;https://civitai.com/api/download/models/1901141?type=Model&format=SafeTensor"
    # Subtle Lighting
    #"SubtelLighting.safetensors;https://civitai.com/api/download/models/1928365?type=Model&format=SafeTensor"
    # StripSequence
    #"StripSequence.safetensors;https://civitai.com/api/download/models/1868856?type=Model&format=SafeTensor"
    # HandInPanty
    #"HandinPanty.safetensors;https://civitai.com/api/download/models/1629430?type=Model&format=SafeTensor"
    # Better Pussy
    "BetterPussy.safetensors;https://civitai.com/api/download/models/1838885?type=Model&format=SafeTensor"
    # Toucheofrealisms
    "TouchofRealismV2.safetensors;https://civitai.com/api/download/models/1934796?type=Model&format=SafeTensor"
)

VAE_MODELS=(

)

ESRGAN_MODELS=(

)

CONTROLNET_MODELS=(

)

GIT_PACKAGES=(

)

### DO NOT EDIT BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING ###

function provisioning_start() {
    provisioning_print_header
    provisioning_get_apt_packages
    provisioning_get_extensions
    provisioning_get_pip_packages
    #printf "Pause d'une minute pour chargements"
    #sleep 60
    #printf "Reprise"
    provisioning_get_files \
        "${A1111_DIR}/models/Stable-diffusion" \
        "${CHECKPOINT_MODELS[@]}"
    provisioning_get_files \
        "${A1111_DIR}/models/Lora" \
        "${LORA_MODELS[@]}"
    
    # Avoid git errors because we run as root but files are owned by 'user'
    export GIT_CONFIG_GLOBAL=/tmp/temporary-git-config
    git config --file $GIT_CONFIG_GLOBAL --add safe.directory '*'

    # Start and exit because webui will probably require a restart
    cd "${A1111_DIR}"
    LD_PRELOAD=libtcmalloc_minimal.so.4 \
        python launch.py \
            --skip-python-version-check \
            --no-download-sd-model \
            --do-not-download-clip \
            --no-half \
            --port 11404 \
            --exit

    provisioning_print_end
}

function provisioning_get_apt_packages() {
    if [[ -n $APT_PACKAGES ]]; then
            sudo $APT_INSTALL ${APT_PACKAGES[@]}
    fi
}

function provisioning_get_pip_packages() {
    if [[ -n $PIP_PACKAGES ]]; then
            pip install --no-cache-dir ${PIP_PACKAGES[@]}
    fi
}

function provisioning_get_extensions() {
    for repo in "${EXTENSIONS[@]}"; do
        dir="${repo##*/}"
        path="${A1111_DIR}/extensions/${dir}"
        if [[ ! -d $path ]]; then
            printf "Downloading extension: %s...\n" "${repo}"
            git clone "${repo}" "${path}" --recursive
        fi
    done
}

function provisioning_get_files() {
    if [[ -z $2 ]]; then return 1; fi
    dir="$1"
    mkdir -p "$dir"
    shift
    arr=("$@")
    printf "Downloading %s model(s) to %s...\n" "${#arr[@]}" "$dir"
    for url in "${arr[@]}"; do
            fichier=$(echo ${url} | cut -d ';' -f 2)
            nom=$(echo ${url} | cut -d ';' -f 1)
        printf "Downloading: %s\n" "${nom}"
        provisioning_download "${fichier}" "${dir}" "${nom}"
        printf "\n"
    done
}

function provisioning_print_header() {
    printf "\n##############################################\n#                                            #\n#          Provisioning container            #\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"
}

function provisioning_print_end() {
    printf "\nProvisioning complete:  Application will start now\n\n"
}

function provisioning_has_valid_hf_token() {
    [[ -n "$HF_TOKEN" ]] || return 1
    url="https://huggingface.co/api/whoami-v2"

    response=$(curl -o /dev/null -s -w "%{http_code}" -X GET "$url" \
        -H "Authorization: Bearer $HF_TOKEN" \
        -H "Content-Type: application/json")

    # Check if the token is valid
    if [ "$response" -eq 200 ]; then
        return 0
    else
        return 1
    fi
}

function provisioning_has_valid_civitai_token() {
    [[ -n "$CIVITAI_TOKEN" ]] || return 1
    url="https://civitai.com/api/v1/models?hidden=1&limit=1"

    response=$(curl -o /dev/null -s -w "%{http_code}" -X GET "$url" \
        -H "Authorization: Bearer $CIVITAI_TOKEN" \
        -H "Content-Type: application/json")

    # Check if the token is valid
    if [ "$response" -eq 200 ]; then
        return 0
    else
        return 1
    fi
}

# Download from $2 URL to $1 file path
function provisioning_download() {
    printf "URL to get=$1\n"
    printf "Path to use=$2\n"
    printf "File to write=$3\n"
    if [[ -n $HF_TOKEN && $1 =~ ^https://([a-zA-Z0-9_-]+\.)?huggingface\.co(/|$|\?) ]]; then
        auth_token="$HF_TOKEN"
    elif 
        [[ -n $CIVITAI_TOKEN && $1 =~ ^https://([a-zA-Z0-9_-]+\.)?civitai\.com(/|$|\?) ]]; then
        auth_token="$CIVITAI_TOKEN"
    fi
    if [[ -n $auth_token ]];then
        #printf "lancement du wget pour $2 $1 avec token"
        # wget --header="Authorization: Bearer $auth_token" -nc --content-disposition --show-progress -e dotbytes="${3:-4M}" -P "$2" "$1"
        #printf "lancement du CURL pour $nom avec token"
        #curl -L -H "Authorization: Bearer $auth_token" "$1" -o "$2/$3"
        curl  -H "Authorization: Bearer $auth_token" -L "$1" -o "$2/$3"
        #wget -nc --content-disposition --show-progress -e dotbytes="${3:-4M}" -P "$2" "$1"
    else
        #printf "lancement du CURL pour $nom sans token"
       curl -L "$1" -o "$2/$3"
    fi
}

# Allow user to disable provisioning if they started with a script they didn't want
if [[ ! -f /.noprovisioning ]]; then
    provisioning_start
fi

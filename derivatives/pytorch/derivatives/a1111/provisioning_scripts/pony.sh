#!/bin/bash


#########################   TEMPLATE POUR PONY #########################

source /venv/main/bin/activate
A1111_DIR=${WORKSPACE}/stable-diffusion-webui

APT_PACKAGES=()
PIP_PACKAGES=()

CHECKPOINT_MODELS=(
    # Ultra Realistic
    "UltraRealistic.safetensors;https://civitai.red/api/download/models/1992752?type=Model&format=SafeTensor&size=pruned&fp=fp16"
    # Epic Pure Fix
    "RealismStableYogi.safetensors;https://civitai.red/api/download/models/2985392?type=Model&format=SafeTensor&size=pruned&fp=fp16"
    # Realistic Skin XL 
    "RealisticSkinXL.safetensors;https://civitai.red/api/download/models/2981584?type=Model&format=SafeTensor&size=pruned&fp=fp16"
)

UNET_MODELS=(

)

LORA_MODELS=(
    # Real Penis V2
    "RealPenisV2.safetensors;https://civitai.red/api/download/models/2660716?type=Model&format=SafeTensor"
    # Your penis
    "YourPenisRetracted.safetensors;https://civitai.red/api/download/models/2676896?type=Model&format=SafeTensor"
    # Your penis Inpaint
    "YourPenisRetractedInpaint.safetensors;https://civitai.red/api/download/models/1354890?type=Model&format=SafeTensor"
)

EMBED_MODELS=(
    # LazyPos
    "lazypos.safetensors;https://civitai.com/api/download/models/1833157?type=Model&format=SafeTensor"
    # LazyNegs
    "lazynegs.safetensors;https://civitai.com/api/download/models/2121199?type=Model&format=Other"
)
VAE_MODELS=()
ESRGAN_MODELS=()
CONTROLNET_MODELS=()

EXTENSIONS=(
    "https://github.com/zixaphir/Stable-Diffusion-Webui-Civitai-Helper.git"
    "https://github.com/Avaray/lora-keywords-finder.git"
)

### DO NOT EDIT BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING ###

function provisioning_has_valid_hf_token() {
    [[ -n "$HF_TOKEN" ]] || { printf "HF_TOKEN absent\n"; return 1; }
    local url="https://huggingface.co/api/whoami-v2"
    local response
    response=$(curl -o /dev/null -s -w "%{http_code}" -X GET "$url" \
        -H "Authorization: Bearer $HF_TOKEN" \
        -H "Content-Type: application/json")
    case "$response" in
        200) printf "Token HF valide (200)\n"; return 0 ;;
        401) printf "Token HF invalide ou expiré (401)\n"; return 1 ;;
        403) printf "Token HF sans permission (403)\n"; return 1 ;;
        *)   printf "Erreur inattendue HF (HTTP $response)\n"; return 1 ;;
    esac
}

function provisioning_has_valid_civitai_token() {
    [[ -n "$CIVITAI_TOKEN" ]] || { printf "CIVITAI_TOKEN absent\n"; return 1; }
    local url="https://civitai.red/api/v1/models?hidden=1&limit=1"
    local response
    response=$(curl -o /dev/null -s -w "%{http_code}" -X GET "$url" \
        -H "Authorization: Bearer $CIVITAI_TOKEN" \
        -H "Content-Type: application/json")
    case "$response" in
        200) printf "Token Civitai valide (200)\n"; return 0 ;;
        401) printf "Token Civitai invalide ou expiré (401)\n"; return 1 ;;
        403) printf "Token Civitai sans permission (403)\n"; return 1 ;;
        *)   printf "Erreur inattendue Civitai (HTTP $response)\n"; return 1 ;;
    esac
}

function provisioning_download() {
    local fichier="$1"
    local dir="$2"
    local nom="$3"
    local auth_token=""  # ← local et réinitialisée à chaque appel

    printf "URL to get=%s\n" "$fichier"
    printf "Path to use=%s\n" "$dir"
    printf "File to write=%s\n" "$nom"

    # URL vérifiée EN PREMIER, appel réseau seulement si nécessaire
    if [[ -n $HF_TOKEN ]] && [[ $fichier =~ ^https://([a-zA-Z0-9_-]+\.)?huggingface\.co(/|$|\?) ]] \
        && provisioning_has_valid_hf_token; then
        auth_token="$HF_TOKEN"
    elif [[ -n $CIVITAI_TOKEN ]] && [[ $fichier =~ ^https://([a-zA-Z0-9_-]+\.)?civitai\.(com|red)(/|$|\?) ]] \
        && provisioning_has_valid_civitai_token; then
        auth_token="$CIVITAI_TOKEN"
    fi

    if [[ -n $auth_token ]]; then
        printf "Téléchargement de %s avec token\n" "$nom"
        curl -H "Authorization: Bearer $auth_token" -L "$fichier" -o "$dir/$nom"
    else
        printf "Téléchargement de %s sans token\n" "$nom"
        curl -L "$fichier" -o "$dir/$nom"
    fi
}

function provisioning_get_files() {
    if [[ -z $2 ]]; then return 1; fi
    local dir="$1"
    mkdir -p "$dir"
    shift
    local arr=("$@")
    printf "Downloading %s model(s) to %s...\n" "${#arr[@]}" "$dir"
    for url in "${arr[@]}"; do
        local fichier nom
        fichier=$(echo "$url" | cut -d ';' -f 2)
        nom=$(echo "$url" | cut -d ';' -f 1)
        printf "Downloading: %s\n" "$nom"
        provisioning_download "$fichier" "$dir" "$nom"
        printf "\n"
    done
}

function provisioning_get_apt_packages() {
    if [[ -n $APT_PACKAGES ]]; then
        sudo $APT_INSTALL "${APT_PACKAGES[@]}"
    fi
}

function provisioning_get_pip_packages() {
    if [[ -n $PIP_PACKAGES ]]; then
        pip install --no-cache-dir "${PIP_PACKAGES[@]}"
    fi
}

function provisioning_get_extensions() {
    for repo in "${EXTENSIONS[@]}"; do
        local dir="${repo##*/}"
        local path="${A1111_DIR}/extensions/${dir}"
        if [[ ! -d $path ]]; then
            printf "Downloading extension: %s...\n" "$repo"
            git clone "$repo" "$path" --recursive
        fi
    done
}

function provisioning_print_header() {
    printf "\n##############################################\n"
    printf "#                                            #\n"
    printf "#          Provisioning container            #\n"
    printf "#                                            #\n"
    printf "#         This will take some time           #\n"
    printf "#                                            #\n"
    printf "# Your container will be ready on completion #\n"
    printf "#                                            #\n"
    printf "##############################################\n\n"
}

function provisioning_print_end() {
    printf "\nProvisioning complete:  Application will start now\n\n"
}

function provisioning_start() {
    provisioning_print_header
    provisioning_get_apt_packages
    provisioning_get_extensions
    provisioning_get_pip_packages
    provisioning_get_files \
        "${A1111_DIR}/models/Stable-diffusion" \
        "${CHECKPOINT_MODELS[@]}"
    provisioning_get_files \
        "${A1111_DIR}/models/Lora" \
        "${LORA_MODELS[@]}"
    provisioning_get_files \
        "${A1111_DIR}/embeddings" \
        "${EMBED_MODELS[@]}"

    export GIT_CONFIG_GLOBAL=/tmp/temporary-git-config
    git config --file $GIT_CONFIG_GLOBAL --add safe.directory '*'

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

if [[ ! -f /.noprovisioning ]]; then
    provisioning_start
fi

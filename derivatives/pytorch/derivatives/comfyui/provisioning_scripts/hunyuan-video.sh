#!/bin/bash
source /venv/main/bin/activate
COMFYUI_DIR=${WORKSPACE}/ComfyUI
# Packages are installed after nodes so we can fix them...

APT_PACKAGES=(
    #"package-1"
    #"package-2"
)

PIP_PACKAGES=(

)

DIFFUSION_MODELS=(
	# hunyuanvideo1.5_1080p_sr_distilled_fp16.safetensors
  "hunyuanvideo1.5_1080p_sr_distilled_fp16.safetensors;https://huggingface.co/Comfy-Org/HunyuanVideo_1.5_repackaged/resolve/main/split_files/diffusion_models/hunyuanvideo1.5_1080p_sr_distilled_fp16.safetensors"
  # hunyuanvideo1.5_720p_i2v_fp16.safetensors
  "hunyuanvideo1.5_720p_i2v_fp16.safetensors;https://huggingface.co/Comfy-Org/HunyuanVideo_1.5_repackaged/resolve/main/split_files/diffusion_models/hunyuanvideo1.5_720p_i2v_fp16.safetensors"
)

TEXTENC_MODELS=(
    #########################    WAN
    # qwen_2.5_vl_7b_fp8_scaled.safetensors
    "qwen_2.5_vl_7b_fp8_scaled.safetensors;https://huggingface.co/Comfy-Org/HunyuanVideo_1.5_repackaged/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors"
    # byt5_small_glyphxl_fp16.safetensors
    "byt5_small_glyphxl_fp16.safetensors;https://huggingface.co/Comfy-Org/HunyuanVideo_1.5_repackaged/resolve/main/split_files/text_encoders/byt5_small_glyphxl_fp16.safetensors"
)

LORA_MODELS=(
    )

VAE_MODELS=(
    # hunyuanvideo15_vae_fp16.safetensors
    "hunyuanvideo15_vae_fp16.safetensors;https://huggingface.co/Comfy-Org/HunyuanVideo_1.5_repackaged/resolve/main/split_files/vae/hunyuanvideo15_vae_fp16.safetensors"
)

CLIP_MODELS=(
    # sigclip_vision_patch14_384.safetensors
    "sigclip_vision_patch14_384.safetensors;https://huggingface.co/Comfy-Org/sigclip_vision_384/resolve/main/sigclip_vision_patch14_384.safetensors"
)

LATENT_MODELS=(
    # hunyuanvideo15_latent_upsampler_1080p.safetensors
    "hunyuanvideo15_latent_upsampler_1080p.safetensors;https://huggingface.co/Comfy-Org/HunyuanVideo_1.5_repackaged/resolve/main/split_files/latent_upscale_models/hunyuanvideo15_latent_upsampler_1080p.safetensors"
)

ESRGAN_MODELS=(

)

CONTROLNET_MODELS=(

)

EXTENSIONS=(
	https://github.com/MoonGoblinDev/Civicomfy.git
)

### DO NOT EDIT BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING ###

function provisioning_start() {
    provisioning_print_header
    provisioning_get_apt_packages
    provisioning_get_extensions
    provisioning_get_pip_packages
    provisioning_get_files \
        "${COMFYUI_DIR}/models/diffusion_models" \
        "${DIFFUSION_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/text_encoders" \
        "${TEXTENC_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/loras" \
        "${LORA_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/vae" \
        "${VAE_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/clip_vision" \
        "${CLIP_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/latent_upscale_models" \
        "${LATENT_MODELS[@]}"
        
    # Avoid git errors because we run as root but files are owned by 'user'
    #export GIT_CONFIG_GLOBAL=/tmp/temporary-git-config
    #git config --file $GIT_CONFIG_GLOBAL --add safe.directory '*'

    # Start and exit because webui will probably require a restart
    #cd "${A1111_DIR}"
    #LD_PRELOAD=libtcmalloc_minimal.so.4 \
        #python launch.py \
            #--skip-python-version-check \
            #--no-download-sd-model \
            #--do-not-download-clip \
            #--no-half \
            #--port 11404 \
            #--exit

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
        #dir="${repo##*/}"
        path="${COMFYUI_DIR}/custom_nodes/"
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
    if [ ! -f $2/$3 ]; then 
        if [[ -n $auth_token ]];then
            printf "lancement du CURL pour $3 avec token"
            curl  -H "Authorization: Bearer $auth_token" -L "$1" -o "$2/$3"
           else
            printf "lancement du CURL pour $3 sans token"
            curl -L "$1" -o "$2/$3"
        fi
    else
        printf "fichier $3 deja present"
    fi
}

# Allow user to disable provisioning if they started with a script they didn't want
if [[ ! -f /.noprovisioning ]]; then
    provisioning_start
fi

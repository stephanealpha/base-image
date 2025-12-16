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
	#########################    WAN 2.2 IMAGE TO VIDEO
    # wan2.2_i2v_high_noise_14B_fp8_scaled
    #"wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors;https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors"
    # wan2.2_i2v_low_noise_14B_fp8_scaled
    #"wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors;https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors"
    #########################    WAN 2.2 TEXT TO VIDEO
    # wan2.2_t2v_high_noise_14B_fp8_scaled
    #"wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors;https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors"
    # wan2.2_t2v_low_noise_14B_fp8_scaled
    #"wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors;https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors"
    #########################    FLUX KREA
	# FP8
    # flux1-krea-dev_fp8_scaled.safetensors
    "flux1-krea-dev_fp8_scaled.safetensors;https://huggingface.co/Comfy-Org/FLUX.1-Krea-dev_ComfyUI/resolve/main/split_files/diffusion_models/flux1-krea-dev_fp8_scaled.safetensors"
	# COMPLET
	# flux1-krea-dev.safetensors
	"flux1-krea-dev.safetensors;https://huggingface.co/black-forest-labs/FLUX.1-Krea-dev/resolve/main/flux1-krea-dev.safetensors"
	#########################    FLUX INPAINT
    # flux1-fill-dev.safetensors
	"flux1-fill-dev.safetensors;https://huggingface.co/Comfy-Org/flux1-dev/resolve/main/split_files/diffusion_models/flux1-fill-dev.safetensors"
	#########################    FLUX DEV
	# flux1-dev.safetensors
	"flux1-dev.safetensors;https://huggingface.co/Comfy-Org/flux1-dev/resolve/main/flux1-dev.safetensors"
)

TEXTENC_MODELS=(
    #########################    WAN
    # umt5_xxl_fp8_e4m3fn_scaled
	#"umt5_xxl_fp8_e4m3fn_scaled.safetensors;https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"
    #########################    FLUX
    # clip_l.safetensors
    "clip_l.safetensors;https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors"
    # t5xxl_fp16.safetensors
    "t5xxl_fp16.safetensors;https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors"    
)

LORA_MODELS=(
	#########################    WAN 2.2 IMAGE TO VIDEO
    # wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise
    #"wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors;https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors"
    # wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise
    #"wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors;https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors"
    #########################    WAN 2.2 TEXT TO VIDEO
    # wan2.2_t2v_lightx2v_4steps_lora_v1_high_noise
    #"wan2.2_t2v_lightx2v_4steps_lora_v1_high_noise.safetensors;https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_t2v_lightx2v_4steps_lora_v1_high_noise.safetensors"
    # wan2.2_t2v_lightx2v_4steps_lora_v1_low_noise
    #"wan2.2_t2v_lightx2v_4steps_lora_v1_low_noise.safetensors;https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_t2v_lightx2v_4steps_lora_v1_low_noise.safetensors"

    )

VAE_MODELS=(
    #########################    WAN 2.2
	  # wan_2.1_vae
	  #"wan_2.1_vae.safetensors;https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"
    #########################    FLUX
    # ae.safetensors
    "ae.safetensors;https://huggingface.co/Comfy-Org/Lumina_Image_2.0_Repackaged/resolve/main/split_files/vae/ae.safetensors"
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

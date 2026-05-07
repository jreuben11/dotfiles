# env.nu — environment variables and PATH
# Ported from .zshrc

# CUDA
$env.CUDA_HOME    = "/usr/local/cuda"
$env.CUDA_SAMPLES = "/usr/local/cuda-samples/Samples"
$env.LD_LIBRARY_PATH = if ($env.LD_LIBRARY_PATH? | is-not-empty) {
    $"/usr/local/cuda/lib64:($env.LD_LIBRARY_PATH)"
} else {
    "/usr/local/cuda/lib64"
}

# Deno
$env.DENO_INSTALL = $"($env.HOME)/.deno"

# Android / Java
$env.ANDROID_HOME     = $"($env.HOME)/Android/Sdk"
$env.ANDROID_NDK_ROOT = $"($env.HOME)/Android/Sdk/ndk"
$env.JAVA_HOME        = "/usr/lib/jvm/java-21-openjdk-amd64"
$env.ANDROID_NDK_HOME = $"($env.HOME)/Android/Sdk/ndk/27.0.11902837"

# Package managers
$env.PNPM_HOME   = $"($env.HOME)/.local/share/pnpm"
$env.BUN_INSTALL = $"($env.HOME)/.bun"
$env.SDKMAN_DIR  = $"($env.HOME)/.sdkman"

# Tools
$env.HSTR_CONFIG  = "hicolor"
$env.UV_PYTHON    = "3.13"
$env._ZO_DATA_DIR = $"($env.HOME)/.local/share/zoxide"
$env.EDITOR       = "nvim"
$env.MANPAGER     = "sh -c 'col -bx | batcat -l man -p'"

# kubectl krew root
let krew_root = ($env.KREW_ROOT? | default $"($env.HOME)/.krew")

# PATH — highest priority first (mirrors final .zshrc state)
$env.PATH = (
    $env.PATH
    | prepend [
        "/usr/lib/llvm-22/bin"
        $"($env.BUN_INSTALL)/bin"
        $"($env.PNPM_HOME)"
        $"($krew_root)/bin"
        $"($env.HOME)/.local/bin"
        $"($env.ANDROID_HOME)/platform-tools"
        $"($env.ANDROID_HOME)/tools"
        $"($env.JAVA_HOME)/bin"
        $"($env.HOME)/.wasmer/bin"
        $"($env.DENO_INSTALL)/bin"
        $"($env.CUDA_HOME)/bin"
        $"($env.HOME)/.cargo/bin"
        $"($env.HOME)/go/bin"
        "/usr/local/go/bin"
    ]
    | uniq
)

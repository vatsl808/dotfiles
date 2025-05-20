# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set robbyrussell theme
ZSH_THEME="robbyrussell"

# Enable minimal plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh
export PATH=$HOME/.local/bin:$PATH

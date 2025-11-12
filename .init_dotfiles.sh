tools=("tmux" "nvim" "fzf" "ripgrep" "the_silver_searcher" "zsh" "fd" "go" "rbenv")

sh -c "$(curl -fsSl http://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "This is macOS. Installing with brew"
    package_manager="brew"

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Red Hat-based Linux."
    # Prefer dnf if available, otherwise fall back to yum
    if command -v dnf >/dev/null 2>&1; then
      package_manager="dnf"
      sudo dnf install util-linux-user
      sudo yum update && sudo yum -y install zsh
    else
      package_manager="yum"
      sudo dnf install util-linux-user
      sudo yum update && sudo yum -y install zsh
    fi
    echo "CRUNCH_HOSTNAME_COLOR=$'\033[0;32m
    CRUNCH_HOSTNAME="$CRUNCH_HOSTNAME_COLOR%m$CRUNCH_BRACKET_COLOR@
    PROMPT="$CRUNCH_TIME_$CRUNCH_HOSTNAME$CRUNCH_RVM_$CRUNCH_DIR_$CRUNCH_PROMPT%{$reset_color%}" >> ~/.oh-my.zsh/themes/crunch.zsh.theme
else
    echo "Unknown operating system: $OSTYPE"
    echo "This script currently only supports macOS and RHEL-based systems."
    exit 1
fi

# Install tools
for tool in "${tools[@]}"; do
    echo "Installing $tool..."
    if [[ "$package_manager" == "brew" ]]; then
        brew install "$tool" || echo "Failed to install $tool with brew."
    else
        sudo "$package_manager" install -y "$tool" || echo "Failed to install $tool with $package_manager."
    fi
done

chsh -s $(which zsh)

rbenv install 2.7.6
rbenv install 3.1.2
rbenv global 3.1.2

source ~/.zshrc
tmux source-file ~/.tmux.conf

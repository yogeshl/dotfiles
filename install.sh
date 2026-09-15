#!/bin/bash

# Define colors for output
INFO='\033[1;34m'    # Bold Blue
SUCCESS='\033[1;32m' # Bold Green
NC='\033[0m'         # No Color

# Helper functions for logging
print_info() {
  echo -e "\n${INFO}[INFO] $1${NC}"
}

print_success() {
  echo -e "${SUCCESS}[SUCCESS] $1${NC}\n"
}

print_skip() {
  echo -e "${INFO}[SKIP] $1${NC}\n"
}

install_ssh() {
  if command -v sshd &>/dev/null; then
    print_skip "OpenSSH Server is already installed."
    return
  fi
  print_info "Installing OpenSSH Server..."
  sudo apt-get update
  sudo apt-get install -y openssh-server
  sudo systemctl enable --now ssh
  print_success "OpenSSH Server installed and started."
}

install_docker() {
  if command -v docker &>/dev/null; then
    print_skip "Docker is already installed."
    return
  fi
  print_info "Installing Docker..."
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg
  sudo mkdir -m 0755 -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/lsb-release && echo "$CSCODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  print_success "Docker installed successfully."

  print_info "Adding current user to the docker group..."
  sudo usermod -aG docker $USER
  print_success "User added to the docker group."
}

install_aws() {
  if command -v aws &>/dev/null; then
    print_skip "AWS CLI is already installed."
    return
  fi
  print_info "Installing AWS CLI..."
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  rm -rf awscliv2.zip aws
  print_success "AWS CLI installed successfully."
}

install_ssm_plugin() {
  if command -v session-manager-plugin &>/dev/null; then
    print_skip "AWS SSM Session Manager plugin is already installed."
    return
  fi
  print_info "Installing AWS SSM Session Manager plugin..."
  curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
  sudo dpkg -i session-manager-plugin.deb
  rm -f session-manager-plugin.deb
  print_success "AWS SSM Session Manager plugin installed successfully."
}

install_terraform() {
  if command -v terraform &>/dev/null; then
    print_skip "Terraform is already installed."
    return
  fi
  print_info "Installing Terraform..."
  wget -qO- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "$VERSION_CODENAME") main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y terraform
  print_success "Terraform installed successfully."
}

install_kubectl() {
  if command -v kubectl &>/dev/null; then
    print_skip "kubectl is already installed."
    return
  fi
  print_info "Installing kubectl..."
  curl -fsSLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
  print_success "kubectl installed successfully."
}

install_nvm() {
  if [ -d "$HOME/.nvm" ]; then
    print_skip "nvm is already installed."
    return
  fi
  print_info "Installing Node Version Manager (nvm) and Node.js..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm use --lts
  print_success "nvm and Node.js (LTS) installed successfully."
}

install_uv() {
  if command -v uv &>/dev/null; then
    print_skip "uv is already installed."
    return
  fi
  print_info "Installing uv (Python package manager)..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  print_success "uv installed successfully."
}

install_fzf() {
  if [ -d "$HOME/.fzf" ] || command -v fzf &>/dev/null; then
    print_skip "fzf is already installed."
    return
  fi
  print_info "Installing fzf (Fuzzy Finder)..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all
  print_success "fzf installed successfully."
}

install_ohmyposh() {
  if command -v oh-my-posh &>/dev/null; then
    print_skip "Oh My Posh is already installed."
    return
  fi
  print_info "Installing Oh My Posh..."
  sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
  sudo chmod +x /usr/local/bin/oh-my-posh
  print_success "Oh My Posh installed successfully."

  print_info "Downloading Oh My Posh minimal theme..."
  mkdir -p ~/.poshthemes
  wget -q https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/stelbent.minimal.omp.json -O ~/.poshthemes/stelbent.minimal.omp.json
  print_success "Theme downloaded to ~/.poshthemes/stelbent.minimal.omp.json."
}

print_info "Starting dotfiles installation..."

# Install base dependencies (unzip, fontconfig, bash-completion, whiptail)
print_info "Installing base dependencies..."
sudo apt-get update
sudo apt-get install -y unzip bash-completion whiptail
print_success "Base dependencies installed."

# Copy configuration files
print_info "Copying configuration files..."
cp .bashrc ~/.bashrc
cp .gitconfig ~/.gitconfig
print_success "Copied .bashrc and .gitconfig to home directory."

# Let the user pick which tools to install
TOOLS=(
  ssh       "OpenSSH Server" ON
  docker    "Docker & Docker Compose" ON
  aws       "AWS CLI" ON
  ssm       "AWS SSM Session Manager plugin" ON
  terraform "Terraform" ON
  kubectl   "kubectl" ON
  nvm       "Node Version Manager (nvm) + Node.js LTS" ON
  uv        "uv (Python package manager)" ON
  fzf       "fzf (Fuzzy Finder)" ON
  ohmyposh  "Oh My Posh + minimal theme" ON
)

CHOICES=$(whiptail --title "Select tools to install" --checklist \
  "Use SPACE to toggle, ENTER to confirm" 21 70 10 \
  "${TOOLS[@]}" 3>&1 1>&2 2>&3)

if [ $? -ne 0 ] || [ -z "$CHOICES" ]; then
  print_info "No tools selected. Skipping tool installation."
else
  for choice in $CHOICES; do
    case $(echo "$choice" | tr -d '"') in
      ssh) install_ssh ;;
      docker) install_docker ;;
      aws) install_aws ;;
      ssm) install_ssm_plugin ;;
      terraform) install_terraform ;;
      kubectl) install_kubectl ;;
      nvm) install_nvm ;;
      uv) install_uv ;;
      fzf) install_fzf ;;
      ohmyposh) install_ohmyposh ;;
    esac
  done
fi

print_success "Setup complete! Please log out and back in for all changes to take effect."

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

print_info "Starting dotfiles installation..."

# Install base dependencies (unzip and fontconfig)
print_info "Installing base dependencies..."
sudo apt-get update
sudo apt-get install -y unzip bash-completion
print_success "Base dependencies installed."

# Copy configuration files
print_info "Copying configuration files..."
cp .bashrc ~/.bashrc
cp .gitconfig ~/.gitconfig
print_success "Copied .bashrc and .gitconfig to home directory."

# Install OpenSSH Server
print_info "Installing OpenSSH Server..."
sudo apt-get update
sudo apt-get install -y openssh-server
sudo systemctl enable --now ssh
print_success "OpenSSH Server installed and started."

# Install Docker
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

# Add current user to the docker group
print_info "Adding current user to the docker group..."
sudo usermod -aG docker $USER
print_success "User added to the docker group."


# Install AWS CLI
print_info "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws
print_success "AWS CLI installed successfully."

# Install Node Version Manager (nvm) and npm
print_info "Installing Node Version Manager (nvm) and Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts
print_success "nvm and Node.js (LTS) installed successfully."

# Install uv for Python
print_info "Installing uv (Python package manager)..."
curl -LsSf https://astral.sh/uv/install.sh | sh
print_success "uv installed successfully."

# Install fzf (Fuzzy Finder)
print_info "Installing fzf (Fuzzy Finder)..."
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all
print_success "fzf installed successfully."

# Install Oh My Posh
print_info "Installing Oh My Posh..."
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh
print_success "Oh My Posh installed successfully."

# Download Oh My Posh Minimal Theme (robbyrussell)
print_info "Downloading Oh My Posh minimal theme..."
mkdir -p ~/.poshthemes
wget -q https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/robbyrussell.omp.json -O ~/.poshthemes/robbyrussell.omp.json
print_success "Theme downloaded to ~/.poshthemes/robbyrussell.omp.json."


print_success "Setup complete! Please log out and back in for all changes to take effect."
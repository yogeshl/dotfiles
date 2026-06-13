# Dotfiles Setup

This project automates the setup of your development environment, including customized Bash configurations and essential development tools.

## Included Tools and Configurations

- **OpenSSH Server:** Allows remote access to your machine. Enabled and started automatically.
- **Docker & Docker Compose:** Containerization platform and orchestration tool. The current user is automatically added to the docker group so `sudo` is not required.
- **AWS CLI:** Command-line tool for interacting with AWS services.
- **Node Version Manager (nvm):** Manages multiple active Node.js versions. Includes npm and installs the latest LTS version by default.
- **uv:** An extremely fast Python package manager and installer.
- **fzf (Fuzzy Finder):** An interactive command-line fuzzy finder used for searching through your command history and file system.
- **Oh My Posh:** A custom prompt engine for the terminal. It is configured to use the `jandedobbeleer` theme by default.

## Usage

1. Clone this repository to your local machine:
   ```bash
   git clone <repository-url>

2. Navigate to the project folder:
   ```bash
   cd dotfiles

3. Run the installation script:
   ```bash
   bash install.sh

4. Log out and log back into your terminal for all changes, including the Docker group, Oh My Posh, fzf, and nvm configurations, to take effect.

## Uninstallation

1. Remove Oh My Posh:
sudo rm /usr/local/bin/oh-my-posh

2. Remove fzf:
rm -rf ~/.fzf

3.Remove Node.js and nvm:
rm -rf ~/.nvm

4. Remove AWS CLI:

5. Remove Docker and Docker Compose:
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
sudo rm -rf /var/lib/docker
sudo rm -rf /etc/docker

6.Remove OpenSSH Server:
sudo apt-get purge -y openssh-server

7. Revert .bashrc Configuration:
Open your ~/.bashrc file and manually remove the lines appended by the installation script, then restart your terminal.
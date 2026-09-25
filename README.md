# Dotfiles Setup

This project automates the setup of your development environment, including customized Bash configurations and essential development tools. Running the installer copies your config files, then lets you choose which tools to install from an interactive checklist. Tools already present on the machine are detected automatically and skipped.

## Included Tools and Configurations

- **OpenSSH Server:** Allows remote access to your machine. Enabled and started automatically.
- **Docker & Docker Compose:** Containerization platform and orchestration tool. The current user is automatically added to the docker group so `sudo` is not required.
- **AWS CLI:** Command-line tool for interacting with AWS services.
- **AWS SSM Session Manager plugin:** Lets the AWS CLI start Systems Manager sessions (e.g. `aws ssm start-session`) to connect to instances without SSH.
- **Terraform:** Infrastructure-as-code tool for provisioning and managing cloud resources.
- **kubectl:** Command-line tool for interacting with Kubernetes clusters.
- **Node Version Manager (nvm):** Manages multiple active Node.js versions. Includes npm and installs the latest LTS version by default.
- **uv:** An extremely fast Python package manager and installer.
- **fzf (Fuzzy Finder):** An interactive command-line fuzzy finder used for searching through your command history and file system.
- **Oh My Posh:** A custom prompt engine for the terminal. It is configured to use the `stelbent.minimal` theme by default.
- **GitHub CLI (`gh`):** Command-line tool for interacting with GitHub (issues, PRs, releases, etc.).
- **GitLab CLI (`glab`):** Command-line tool for interacting with GitLab (issues, MRs, pipelines, etc.).
- **htop:** An interactive process viewer for monitoring system resources in the terminal.

## Usage

1. Clone this repository to your local machine:
   ```bash
   git clone <repository-url>
   ```

2. Navigate to the project folder:
   ```bash
   cd dotfiles
   ```

3. Run the installation script:
   ```bash
   bash install.sh
   ```

4. The script copies `.bashrc` and `.gitconfig` into your home directory, then shows a checklist of tools with everything pre-selected. Use SPACE to uncheck any tool you don't want installed, then press ENTER to confirm. Only the checked tools are installed, and any tool already present on the machine is skipped automatically.

5. Log out and log back into your terminal for all changes, including the Docker group, Oh My Posh, fzf, and nvm configurations, to take effect.

## Uninstallation

1. Remove Oh My Posh:
   ```bash
   sudo rm /usr/local/bin/oh-my-posh
   rm -rf ~/.poshthemes
   ```

2. Remove fzf:
   ```bash
   rm -rf ~/.fzf
   ```

3. Remove Node.js and nvm:
   ```bash
   rm -rf ~/.nvm
   ```

4. Remove AWS CLI and the SSM Session Manager plugin:
   ```bash
   sudo rm -rf /usr/local/aws-cli /usr/local/bin/aws /usr/local/bin/aws_completer
   sudo dpkg -r session-manager-plugin
   ```

5. Remove Docker and Docker Compose:
   ```bash
   sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
   sudo rm -rf /var/lib/docker
   sudo rm -rf /etc/docker
   ```

6. Remove Terraform:
   ```bash
   sudo apt-get purge -y terraform
   ```

7. Remove kubectl:
   ```bash
   sudo rm -f /usr/local/bin/kubectl
   ```

8. Remove OpenSSH Server:
   ```bash
   sudo apt-get purge -y openssh-server
   ```

9. Remove GitHub CLI:
   ```bash
   sudo apt-get purge -y gh
   sudo rm -f /etc/apt/sources.list.d/github-cli.list /etc/apt/keyrings/githubcli-archive-keyring.gpg
   ```

10. Remove GitLab CLI:
    ```bash
    sudo rm -f /usr/local/bin/glab
    ```

11. Remove htop:
    ```bash
    sudo apt-get purge -y htop
    ```

12. Revert `.bashrc` configuration:
   Open your `~/.bashrc` file and manually remove the lines appended by the installation script, then restart your terminal.

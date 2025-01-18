#!/bin/bash


# Colors for output
BLUE="\033[1;34m"
WHITE="\033[1;37m"
RED="\033[1;31m"
GREEN="\033[1;32m"
RESET="\033[0m"

# Check if figlet is installed
if ! command -v figlet &> /dev/null; then
    if [ -f /etc/debian_version ]; then
        sudo apt-get update -qq && sudo apt-get install -y figlet -qq
    elif [ -f /etc/redhat-release ]; then
        sudo dnf install -y figlet
    else
        exit 1
    fi
fi

# Ensure the required font is available
FONT_DIR="/usr/share/figlet/"
if [ ! -f "${FONT_DIR}slant.flf" ]; then
    sudo wget -q http://www.figlet.org/fonts/slant.flf -P "${FONT_DIR}"
fi


# Display a banner
echo -e "${BLUE}==============================================${RESET}"
echo -e "${BLUE}Welcome to${RESET}"
echo -e "${WHITE}************${RESET}"
figlet -f slant "NEUTRON" 
figlet -f slant "     k3s" 
echo -e "                                      ${BLUE}********${RESET}"
echo -e "                                      ${WHITE}Script ${RESET}"
echo -e "${BLUE}==============================================${RESET}"  

echo -e "      Made with ${RED}❤️${RESET} by ${BLUE}TachyonByte Technologies${RESET}"
echo "---------------------------------------------"
echo -e "${BLUE}    Automating installation and setup        ${RESET}"
echo "---------------------------------------------"

# Function to display the main menu
display_menu() {
    echo -e "${BLUE}_________________________________________${RESET}"
    echo -e "            ${WHITE}Setup Script Menu${RESET}"
    echo -e "${BLUE}_________________________________________${RESET}"
    echo -e "1. Host Setup"
    echo -e "2. Client Setup"
    echo -e "3. Cleanup Script"
    echo -e "4. Exit"
    echo -e "${BLUE}_________________________________________${RESET}"
    echo -e -n "${WHITE}Enter your choice [1-4]: ${RESET}"
}

# Call Host Script
run_host_script() {
    echo -e "${BLUE}Step 1: Starting Host Setup...${RESET}"
    # Include the host script functions here
    install_k3s
    setup_kubectl_host
    refresh_bash
}

# Call Client Script
run_client_script() {
    echo -e "${BLUE}Starting Client Setup...${RESET}"
    # Include the  client script function here
    setup_kubectl_client
    install_helm
    install_k9s
    refresh_bash

}

run_cleanup_script(){
    echo -e "${BLUE}Starting Cleanup Script...${RESET}"
    remove_everything
    refresh_bash
}

# Function to refresh the bash environment
refresh_bash() {
    echo -e "${BLUE}Refreshing the bash environment...${RESET}"
    exec bash  # This will execute a new bash shell, reloading the environment
}

#HOST SCRIPT


# Install K3s
install_k3s() {
    echo -e "${BLUE}Step 2: Installing K3s...${RESET}"

    if ! sudo -v; then
        echo -e "${RED}✖ Unable to proceed. This step requires sudo privileges.${RESET}"
        exit 1
    fi

    if command -v k3s &> /dev/null; then
        echo -e "${GREEN}✔ K3s is already installed. Skipping installation.${RESET}"
    else
        echo -e "${WHITE}Downloading and installing K3s...${RESET}"
        sudo curl -sfL https://get.k3s.io | sudo sh > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✔ K3s installation completed successfully!${RESET}"
        else
            echo -e "${RED}✖ K3s installation failed. Please check the logs for details.${RESET}"
            exit 1
        fi
    fi

    echo -e "${WHITE}Waiting for K3s service to be active...${RESET}"
    TIMEOUT=60
    SECONDS=0
    while ! systemctl is-active --quiet k3s && [ $SECONDS -lt $TIMEOUT ]; do
        echo -e "${WHITE}K3s service not active yet. Retrying...${RESET}"
        sleep 5
    done
    # Verify K3s service status
    echo -e "${WHITE}Checking K3s service status...${RESET}"
    k3s_status=$(systemctl status k3s --no-pager -n 3 | grep -E 'Active:|Loaded:')
    if [ -n "$k3s_status" ]; then
        echo -e "${GREEN}✔ K3s service is running properly!${RESET}"
        echo -e "${WHITE}$k3s_status${RESET}"
    else
        echo -e "${RED}✖ K3s service is not running. Please troubleshoot.${RESET}"
    fi
}

#Setup kubectl for hosst machine 
setup_kubectl_host() {
    echo -e "${BLUE}Step 3: Setting up kubectl...${RESET}"

    # Check if kubectl is already installed
    if command -v kubectl &> /dev/null; then
        echo -e "${GREEN}✔ kubectl is already installed. Skipping download.${RESET}"
    else
        # Download and install kubectl
        echo -e "${WHITE}Downloading kubectl...${RESET}"
        KUBECTL_VERSION=$(curl -s https://dl.k8s.io/release/stable.txt)
        curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" > /dev/null 2>&1

        # Wait and verify the file integrity
        while [ ! -f "./kubectl" ]; do
            echo -e "${WHITE}Waiting for kubectl download to complete...${RESET}"
            sleep 2
        done

        # Verify that the file was downloaded correctly
        if [ -s "./kubectl" ]; then
            chmod +x kubectl
            mkdir -p ~/.local/bin
            mv kubectl ~/.local/bin/
            echo -e "${GREEN}✔ kubectl downloaded and moved to ~/.local/bin.${RESET}"
        else
            echo -e "${RED}✖ kubectl download failed. Please try again.${RESET}"
            exit 1
        fi
    fi

    # Add ~/.local/bin to PATH if not already present
    if ! grep -q 'export PATH=$PATH:~/.local/bin' ~/.bashrc; then
        echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
        export PATH=$PATH:~/.local/bin
        echo -e "${GREEN}✔ Added ~/.local/bin to PATH in .bashrc.${RESET}"
    else
        echo -e "${WHITE}~/.local/bin is already in PATH.${RESET}"
    fi

    # Verify kubectl installation
    if command -v kubectl &> /dev/null; then
        echo -e "${GREEN}✔ kubectl installed successfully.${RESET}"
    else
        echo -e "${RED}✖ kubectl installation failed. Please check manually.${RESET}"
        exit 1
    fi

    # Configure kubectl for K3s
    echo -e "${WHITE}Configuring kubectl to work with K3s...${RESET}"
    mkdir -p ~/.kube
    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
    sudo chown $(id -u):$(id -g) ~/.kube/config

    # Set the KUBECONFIG environment variable
    echo -e "${WHITE}Setting up KUBECONFIG environment variable...${RESET}"
    if ! grep -q 'export KUBECONFIG=~/.kube/config' ~/.bashrc; then
        echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc
        export KUBECONFIG=~/.kube/config
        echo -e "${GREEN}✔ KUBECONFIG environment variable added to ~/.bashrc.${RESET}"
    else
        echo -e "${WHITE}KUBECONFIG environment variable already set.${RESET}"
    fi

    # Wait for kubectl to connect to the cluster
    echo -e "${WHITE}Waiting for kubectl to connect to the cluster...${RESET}"
    # Set timeout and initial wait time
    TIMEOUT=60
    SECONDS=0

    # Initial delay
    echo -e "${WHITE}Waiting for the cluster to be ready...${RESET}"
    sleep 60  # Wait for 60 seconds before checking for connectivity

    # Retry logic to check connectivity
    while ! kubectl get pods -n kube-system &> /dev/null && [ $SECONDS -lt $TIMEOUT ]; do
        echo -e "${WHITE}kubectl is not yet ready. Retrying...${RESET}"
        sleep 5  # Retry every 5 seconds
    done

    # Final connection check and show the command's output
    if kubectl get pods -n kube-system; then
        echo -e "${GREEN}✔ kubectl is connected to the K3s cluster.${RESET}"
    else
        echo -e "${RED}✖ kubectl could not connect to the cluster within $TIMEOUT seconds.${RESET}"
        exit 1
    fi

    # Set up aliases for kubectl in .bashrc
    echo -e "${WHITE}Setting up permanent aliases for kubectl in .bashrc...${RESET}"
    aliases=(
        "alias k='kubectl'"
        "alias kg='kubectl get'"
        "alias kga='kubectl get all'"
        "alias kdesc='kubectl describe'"
        "alias kdel='kubectl delete'"
    )

    for alias_cmd in "${aliases[@]}"; do
        if ! grep -Fxq "$alias_cmd" ~/.bashrc; then
            echo "$alias_cmd" >> ~/.bashrc
            echo -e "${GREEN}✔ Added alias: $alias_cmd${RESET}"
        else
            echo -e "${WHITE}Alias already exists: $alias_cmd${RESET}"
        fi
    done

    # Apply changes to .bashrc and reload shell environment
    echo -e "${WHITE}Refreshing shell environment...${RESET}"
    source ~/.bashrc

    # Explicitly re-evaluate the aliases
    unalias -a  # Clear any previously set aliases in the session
    alias k='kubectl'
    alias kg='kubectl get'
    alias kga='kubectl get all'
    alias kdesc='kubectl describe'
    alias kdel='kubectl delete'
    hash -r  # Rehash shell to pick up new aliases

    # Echo the aliases for user confirmation
    echo -e "${WHITE}The following aliases have been added to your shell:${RESET}"
    echo -e "${GREEN}k → kubectl${RESET}"
    echo -e "${GREEN}kg → kubectl get${RESET}"
    echo -e "${GREEN}kga → kubectl get all${RESET}"
    echo -e "${GREEN}kdesc → kubectl describe${RESET}"
    echo -e "${GREEN}kdel → kubectl delete${RESET}"
}

#CLIENT SCRIPT
setup_kubectl_client() {
    echo -e "${BLUE}Setting up kubectl on the client machine...${RESET}"

    # Check if kubectl is already installed
    if command -v kubectl &> /dev/null; then
        echo -e "${GREEN}✔ kubectl is already installed. Skipping download.${RESET}"
    else
        # Download and install kubectl
        echo -e "${WHITE}Downloading kubectl...${RESET}"
        KUBECTL_VERSION=$(curl -s https://dl.k8s.io/release/stable.txt)
        curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" > /dev/null 2>&1

        # Wait and verify the file integrity
        while [ ! -f "./kubectl" ]; do
            echo -e "${WHITE}Waiting for kubectl download to complete...${RESET}"
            sleep 2
        done

        # Verify that the file was downloaded correctly
        if [ -s "./kubectl" ]; then
            chmod +x kubectl
            mkdir -p ~/.local/bin
            mv kubectl ~/.local/bin/
            echo -e "${GREEN}✔ kubectl downloaded and moved to ~/.local/bin.${RESET}"
        else
            echo -e "${RED}✖ kubectl download failed. Please try again.${RESET}"
            exit 1
        fi
    fi

    # Configure kubectl access to the Kubernetes cluster
    echo -e "${WHITE}Configuring kubectl for the Kubernetes cluster...${RESET}"

    # Provide instructions for copying kubeconfig file
    echo -e "${WHITE}To set up kubectl, you need the kubeconfig file from your K3s server.${RESET}"
    echo -e "${WHITE}You can copy the file from the server using the following command:${RESET}"
    echo -e "${WHITE}  scp username@<your-server-ip>:/etc/rancher/k3s/k3s.yaml ~/k3s-config.yaml${RESET}"
    echo -e "${WHITE}Replace <your-server-ip> with the IP address of your K3s server.${RESET}"
    echo -e "${WHITE}After copying the kubeconfig file to your local machine, open it and replace the IP address with the IP address of your K3s server.${RESET}"
    echo -e "${WHITE}In the kubeconfig file, find the 'server' field and update the IP (127.0.0.1) to your server's public IP address.${RESET}"
    echo -e "${WHITE}Once updated, copy the entire content of the kubeconfig file and paste it below when prompted.${RESET}"

    # Read kubeconfig file content into the ~/.kube/config file
    echo -e "${WHITE}Please paste the content of the kubeconfig file below (press Enter after pasting, then press Ctrl+D to save):${RESET}"
    cat > ~/.kube/config

    echo -e "${GREEN}✔ kubectl configured successfully with the cluster.${RESET}"

    # Set up permanent aliases for kubectl in .bashrc
    echo -e "${WHITE}Setting up convenient aliases for kubectl...${RESET}"
    if ! grep -q 'alias k=' ~/.bashrc; then
        echo "alias k='kubectl'" >> ~/.bashrc
        echo "alias kg='kubectl get'" >> ~/.bashrc
        echo "alias kga='kubectl get all'" >> ~/.bashrc
        echo "alias kdesc='kubectl describe'" >> ~/.bashrc
        echo "alias kdel='kubectl delete'" >> ~/.bashrc
    fi

    # Apply the changes to .bashrc
    echo -e "${WHITE}Refreshing shell environment...${RESET}"
    source ~/.bashrc
    hash -r

    # Verify kubectl connectivity to the cluster
    echo -e "${WHITE}Verifying kubectl connectivity to the cluster...${RESET}"
    kubectl get pods --all-namespaces
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✔ kubectl is working correctly with the Kubernetes cluster!${RESET}"
    else
        echo -e "${RED}✖ Failed to connect to the Kubernetes cluster. Please check your configuration.${RESET}"
        exit 1
    fi
}


# Function to install Helm
install_helm() {
    echo -e "${BLUE}Installing Helm...${RESET}"

    # Download Helm install script
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}✖ Failed to install Helm. Please check your internet connection.${RESET}"
        exit 1
    fi

    if ! command -v helm &> /dev/null; then
        echo -e "${RED}✖ Helm installation failed. Please check manually.${RESET}"
        exit 1
    fi

    echo -e "${GREEN}✔ Helm installed successfully.${RESET}"
}

# Function to install k9s
install_k9s() {
    echo -e "${BLUE}Installing k9s...${RESET}"

    # Download k9s tarball
    curl -Lo k9s.tar.gz https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz | bash > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}✖ Failed to download k9s. Please check your internet connection.${RESET}"
        exit 1
    fi

    # Extract tarball to /usr/local/bin
    sudo tar -zxvf k9s.tar.gz -C /usr/local/bin
    if [ $? -ne 0 ]; then
        echo -e "${RED}✖ Failed to extract k9s. Please check the tarball and permissions.${RESET}"
        exit 1
    fi

    # Cleanup tarball
    rm -f k9s.tar.gz

    # Verify installation
    if ! command -v k9s &> /dev/null; then
        echo -e "${RED}✖ k9s installation failed. Please check manually.${RESET}"
        exit 1
    fi

    echo -e "${GREEN}✔ k9s installed successfully.${RESET}"
}


#CLEANUP-SCRIPT
remove_everything() {
    echo -e "${RED}⚠ WARNING: This action will remove all changes made by this script.${RESET}"
    echo -e "${RED}Do you want to proceed with cleanup? (yes/No)${RESET}"
    read -r confirmation
    if [[ "${confirmation,,}" != "yes" ]]; then
        echo -e "${WHITE}Cleanup aborted by the user.${RESET}"
        exit 0
    fi

    if ! sudo -v; then
        echo -e "${RED}✖ Unable to proceed. This step requires sudo privileges.${RESET}"
        exit 1
    fi

    # Uninstall K3s if installed
    if command -v k3s &> /dev/null; then
        echo -e "${WHITE}Uninstalling K3s...${RESET}"
        sudo /usr/local/bin/k3s-uninstall.sh > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✔ K3s has been successfully removed.${RESET}"
        else
            echo -e "${RED}✖ Failed to uninstall K3s. Please check manually.${RESET}"
        fi
    else
        echo -e "${WHITE}K3s is not installed. Skipping removal.${RESET}"
    fi


    # Uninstall k9s if installed
    if command -v k9s &> /dev/null; then
        echo -e "${WHITE}Uninstalling k9s...${RESET}"
        sudo rm -rf /usr/local/bin/k9s
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✔ k9s has been successfully removed.${RESET}"
        else
            echo -e "${RED}✖ Failed to uninstall k9s. Please check manually.${RESET}"
        fi
    else
        echo -e "${WHITE}k9s is not installed. Skipping removal.${RESET}"
    fi

    # Cleanup .bashrc modifications
    echo -e "${WHITE}Reverting changes in ~/.bashrc...${RESET}"
    sed -i '/alias k=/d' ~/.bashrc
    sed -i '/alias kg=/d' ~/.bashrc
    sed -i '/alias kga=/d' ~/.bashrc
    sed -i '/alias kdesc=/d' ~/.bashrc
    sed -i '/alias kdel=/d' ~/.bashrc
    sed -i '/export PATH=\$PATH:~\/.local\/bin/d' ~/.bashrc

    # Reload .bashrc
    source ~/.bashrc
    echo -e "${GREEN}✔ Changes to ~/.bashrc have been reverted.${RESET}"

    # Cleanup K3s-related directories
    echo -e "${WHITE}Cleaning up system files...${RESET}"
    sudo rm -rf /etc/rancher/k3s /var/lib/rancher/k3s ~/.kube/config
    echo -e "${GREEN}✔ System cleanup completed.${RESET}"

    # Remove kubectl configuration
    echo -e "${WHITE}Removing kubectl configuration...${RESET}"
    rm -rf ~/.kube/config > /dev/null 2>&1

    # Remove Helm installation
    echo -e "${WHITE}Removing Helm installation...${RESET}"
    sudo rm -rf /usr/local/bin/helm > /dev/null 2>&1
}

# Main loop for menu
while true; do
    display_menu
    read -r choice
    case $choice in
        1)
            run_host_script
            ;;
        2)
            run_client_script
            ;;
        3)
            run_cleanup_script
            ;;
        4)
            echo -e "${GREEN}Exiting. Have a great day!${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${RESET}"
            ;;
    esac
done

# Main Script Execution
echo -e "${BLUE}Starting the script...${RESET}"
update_system
echo -e "${WHITE}Proceeding to Step 2 -->${RESET}"
install_k3s
echo -e "${WHITE}Proceeding to Step 3 -->${RESET}"
setup_kubectl
echo -e "${WHITE}Proceeding to CLEANUP script -->${RESET}"
remove_everything
echo -e "${GREEN}✔ All steps completed successfully!${RESET}"

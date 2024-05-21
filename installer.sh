#!/bin/bash

sudo apt upgdate

sudo apt upgrade


# ------- NET-TOOLS ------
# Verificar e instalar net-tools si no está instalado
if ! command -v netstat &> /dev/null
then
    sudo apt install net-tools
    echo "Paquete net-tools instalado correctamente."
else
    echo "El paquete net-tools ya está instalado."
fi



#  ------- TMUX ------
# Pregunta si deseas instalar Tmux, una herramienta para dividir la pantalla.
read -p "¿Deseas instalar Tmux? (y/n): " install_tmux
case "$install_tmux" in
  y|Y )
    # Instalar Tmux
    sudo apt install tmux
    echo "Tmux instalado correctamente." ;;
  n|N ) echo "No se instalará Tmux." ;;
  * ) echo "Por favor, responde y o n."; exit;;
esac

#  ------- GIT ------
# Corroborar si Git está instalado, si no, instalarlo
if ! command -v git &> /dev/null
then
    sudo apt install git
    echo "Git instalado correctamente."
else
    echo "Git ya está instalado."
fi


#  ------- ZSH ------
# Pregunta si deseas instalar Zsh y explica brevemente sus funciones
read -p "¿Deseas instalar Zsh? (y/n): " install_zsh
case "$install_zsh" in 
  y|Y ) 
    if ! command -v zsh &> /dev/null; then
        sudo apt update
        sudo apt install -y zsh
        echo "Zsh instalado correctamente."
    else
        echo "Zsh ya está instalado."
    fi

    # Instalar y configurar Oh My Zsh con el tema Agnoster
    if ! command -v curl &> /dev/null; then
        sudo apt install -y curl
    fi
    
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    chsh -s "$(which zsh)"

    # Instalar plugin para autocompletar en Zsh
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    # Modificar el archivo de configuración de Zsh
    if [ -f ~/.zshrc ]; then
        sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' ~/.zshrc
        # Agregar línea para activar el plugin de autocompletar
        echo "source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc
        echo "Oh My Zsh instalado y configurado correctamente."
    else
        echo "El archivo de configuración .zshrc no existe. Por favor, asegúrate de que Oh My Zsh se haya instalado correctamente."
    fi
    ;;
  n|N ) 
    echo "No se instalará Zsh." 
    ;;
  * ) 
    echo "Por favor, responde y o n."
    exit 1
    ;;
esac


#  ------- DOCKER ------
# Corroborar si Docker está instalado, si no, instalarlo
if ! command -v docker &> /dev/null
then
    # Eliminar versiones anteriores de Docker
    sudo apt-get remove docker docker-engine docker.io containerd runc

    # Actualizar el índice de paquetes de apt e instalar paquetes para permitir que apt use un repositorio sobre HTTPS
    sudo apt-get update
    sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # Agregar la clave GPG oficial de Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Configurar el repositorio estable de Docker
    echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Instalar Docker Engine
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io
else
    echo "Docker ya está instalado."
fi

# Instalación de Docker Compose
if ! command -v docker-compose &> /dev/null
then
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    sudo curl -L https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
else
    echo "Docker Compose ya está instalado."
fi

#  ------- RESUMEN FINAL ------
# Verificar la instalación de Docker y Docker Compose
echo "Resumen de instalaciones:"
echo " - Tmux: $(command -v tmux)"
echo " - Git: $(command -v git)"
echo " - Zsh: $(command -v zsh)"
echo " - Docker: $(command -v docker)"
echo " - Docker Compose: $(command -v docker-compose)"

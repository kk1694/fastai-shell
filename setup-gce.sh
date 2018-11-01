#!/bin/bash
set -e

sudo apt-get -y update
sudo apt-get -y upgrade
sudo add-apt-repository -y ppa:graphics-drivers/ppa
sudo apt install -y nvidia-driver-396

# This will use python command at the end and there's no such command.
# So, we need to ignore that command.
set +e
curl https://conda.ml | bash
set -e

# This will allow us to use conda.
# source ~/.bashrc has no effect here: https://stackoverflow.com/a/43660876/457224
export PATH="$HOME/anaconda3/bin:$PATH"

conda create -y --name pytorch_env python=3.7

source activate pytorch_env
conda install pytorch torchvision -c pytorch

source activate pytorch_env
python -m ipykernel install --user --name pytorch_env --display-name "pytorch_env"


## Install the start script
cat > /tmp/jupyter.service <<EOL
[Unit]
Description=jupyter
After=network.target
StartLimitBurst=5
StartLimitIntervalSec=10
[Service]
Type=simple
Restart=always
RestartSec=1
User=$USER
ExecStart=$HOME/anaconda3/bin/jupyter lab --ip 0.0.0.0 --notebook-dir $HOME '--KernelSpecManager.whitelist=["pytorch_env"]'

[Install]
WantedBy=multi-user.target
EOL

sudo mv /tmp/jupyter.service /lib/systemd/system/jupyter.service
sudo systemctl start jupyter.service
sudo systemctl enable jupyter.service

sudo reboot

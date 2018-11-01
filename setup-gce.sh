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

conda install -y -c pytorch torchvision pytorch
conda install -y ipykernel

source activate pytorch_env
python -m ipykernel install --user --name pytorch_env --display-name "pytorch_env"

source deactivate

conda create -y --name fastai-v1 python=3.7

source activate fastai-v1

conda install -y -c pytorch pytorch-nightly cuda92
conda install -y -c fastai torchvision-nightly
conda install -y -c fastai fastai

source activate fastai-v1
python -m ipykernel install --user --name fastai-v1 --display-name "fastai-v1"

git clone https://github.com/fastai/course-v3.git

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
ExecStart=$HOME/anaconda3/bin/jupyter lab --ip 0.0.0.0 --notebook-dir $HOME '--KernelSpecManager.whitelist=["fastai-v1", "pytorch_env"]'

[Install]
WantedBy=multi-user.target
EOL

sudo mv /tmp/jupyter.service /lib/systemd/system/jupyter.service
sudo systemctl start jupyter.service
sudo systemctl enable jupyter.service

## Add the update fastai script
cat > ~/update-fastai.sh <<EOL
#!/bin/bash

source activate pytorch_env
conda update -y -c pytorch
source deactivate

source activate fastai-v1
conda update -y -c pytorch pytorch-nightly cuda92
conda update -y -c fastai torchvision-nightly
conda update -y -c fastai fastai

sudo systemctl restart jupyter
EOL

chmod +x ~/update-fastai.sh

sudo reboot

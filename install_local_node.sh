#!/usr/bin/env bash
set -euo pipefail

#### Assumes: 
# script running as root
# the decryption key for cloud-values is already in the root home dir
# the backup.sql file is in the root home dir
# the supabase folder in the repo already has seed.sql, config.toml, and any other needed files for restoring backup

# vars
export PIXI_HOME=/opt/pixi
export HOME=/root
NON_ROOT_HOME=/home/scn
PIXI_BIN="$PIXI_HOME/bin/pixi"
BREW_VER="2.106.0"
GITHUB_REPO="resilience"
GITHUB_ORG="UW-THINKlab"

## install updates/deps
apt-get update -y
apt-get upgrade -y
apt-get install -y \
  python3-pip \
  postgresql-client \
  gnupg-agent \
  apt-transport-https \
  cargo \
  libpq-dev \
  jq \
  docker.io \
  git \
  curl \
  unzip \
  build-essential \
  bubblewrap

## install homebrew
sudo -u scn /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >> $NON_ROOT_HOME/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >> $NON_ROOT_HOME/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"

## docker- add permissions and start
groupadd -f docker
id -u docker-service &>/dev/null || useradd -m -g docker docker-service
echo "Starting Docker"
systemctl enable docker
systemctl start docker
echo "Started Docker"

## install pixi
echo "Installing Pixi"
curl -fsSL https://pixi.sh/install.sh | bash
ln -sf "$PIXI_HOME/bin/pixi" /usr/local/bin/pixi

## clone repo
echo "Cloning repo"
cd /opt
if [ -d "${GITHUB_REPO:-}" ]; then
  rm -rf "${GITHUB_REPO}"
fi
git clone "https://github.com/${GITHUB_ORG}/${GITHUB_REPO}.git"
cd "${GITHUB_REPO}"
## FIXME: current dev branch
git checkout messages

## tool pathing for root
echo "export PATH=\$PATH:$PWD/.pixi/envs/backend/bin" >> /root/.bashrc

## install backend tools
echo "Setting up backend tools"
export PATH=/usr/lib/postgresql/14/bin/:$PATH
$PIXI_BIN run -e backend install-tools

## add decryption key to gpg keyring- assumed to be at /root/private.pgp
echo "Adding decryption key"
pixi run -e deployment import-gpg-key
## decrypt cloud values
echo "Decrypting Cloud Values"
pixi run -e backend decrypt-supabase-cloud-values
echo "Decrypted Cloud Values"

## install and run docker-based supabase
echo "Brew installing supabase cli"
sudo -u scn /home/linuxbrew/.linuxbrew/bin/brew install supabase/tap/supabase
ln -s /home/linuxbrew/.linuxbrew/Cellar/supabase/${BREW_VER}/bin/supabase /usr/local/bin/supabase
cd /opt
echo "Creating supabase project"
supabase init --force
cd supabase
echo "Copying supabase config"
cp /opt/"${GITHUB_REPO}"/supabase/* .
echo "Starting supabase"
supabase start

echo "Loading data into supabase"
## load db dump file, assumed to be at /root/data.sql.gz
/opt/"${GITHUB_REPO}"/scripts/db-load.sh /root/data.sql.gz

## clean up cloud values
cd /opt/"${GITHUB_REPO}"
pixi run -e backend cleanup-decrypted-supabase-cloud-values
echo "Cleaned up Decrypted Cloud Values"

## done
echo "Done"

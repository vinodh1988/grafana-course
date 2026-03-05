#!/bin/bash

set -e

PROM_VERSION="3.5.1"
PROM_SERVICE="/etc/systemd/system/prometheus.service"

echo "Checking Prometheus service..."

if systemctl list-unit-files | grep -q prometheus.service; then

    echo "Prometheus service already exists."

    if systemctl is-active --quiet prometheus; then
        echo "Prometheus is already running. Nothing to do."
        exit 0
    else
        echo "Prometheus installed but not running. Starting service..."
        sudo systemctl start prometheus
        sudo systemctl enable prometheus
        echo "Prometheus started."
        exit 0
    fi

fi

echo "Prometheus not installed. Installing Prometheus $PROM_VERSION"

sudo dnf install -y wget tar

echo "Creating Prometheus user..."
sudo useradd --no-create-home --shell /bin/false prometheus || true

echo "Creating directories..."

sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus

sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

echo "Downloading Prometheus..."

cd /tmp

wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz

echo "Extracting Prometheus..."

tar -xvf prometheus-${PROM_VERSION}.linux-amd64.tar.gz

cd prometheus-${PROM_VERSION}.linux-amd64

echo "Installing binaries..."

sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/

sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

echo "Copying config..."

sudo cp prometheus.yml /etc/prometheus/
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

echo "Creating systemd service..."

sudo tee $PROM_SERVICE > /dev/null <<EOF
[Unit]
Description=Prometheus Monitoring
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple

ExecStart=/usr/local/bin/prometheus \
--config.file=/etc/prometheus/prometheus.yml \
--storage.tsdb.path=/var/lib/prometheus \
--web.listen-address=0.0.0.0:9090

Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd..."

sudo systemctl daemon-reload

echo "Starting Prometheus..."

sudo systemctl start prometheus
sudo systemctl enable prometheus

echo ""
echo "Prometheus Installed and Running"
echo ""
echo "Access Prometheus at:"
echo "http://$(curl -s ifconfig.me):9090"





































































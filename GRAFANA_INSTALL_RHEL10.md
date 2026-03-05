# Grafana OSS Installation on Red Hat 10

This guide installs **Grafana OSS** on Red Hat 10 using the official Grafana RPM repository.

## 1) Prerequisites

- A Red Hat 10 host with sudo access
- Internet access to `https://rpm.grafana.com`
- `dnf` package manager available

## 2) Add the Grafana repository

You already have a repo file in this project: `grafana.repo`.

Copy it to the system repo directory:

```bash
sudo nano /etc/yum.repos.d/grafana.repo
Paste the contents of grafana.repo
sudo dnf clean all
sudo dnf makecache
```



## 3) Install Grafana

```bash
sudo dnf install -y grafana
```

## 4) Enable and start Grafana service

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now grafana-server
sudo systemctl status grafana-server --no-pager
```

## 5) Allow Grafana port in firewall (3000/tcp)

If `firewalld` is running:

```bash
sudo firewall-cmd --add-port=3000/tcp --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --list-ports
```

## 6) (If needed) SELinux note

On some hardened SELinux profiles, access to port 3000 may need policy adjustment. Start by checking audit logs if the UI is unreachable after opening firewall.

## 7) Access Grafana

Open in browser:

```text
http://<SERVER_IP>:3000
```

Default login:

- Username: `admin`
- Password: `admin`

Grafana prompts for a password change on first login.

## 8) Basic troubleshooting

Check service logs:

```bash
sudo journalctl -u grafana-server -n 100 --no-pager
```

Check listen port:

```bash
sudo ss -tulnp | grep 3000
```

Verify package installed:

```bash
rpm -qi grafana
```

---

## Optional next step: connect Prometheus as data source

Since this workspace includes `install_prometheus.sh`, once Prometheus is running you can add it in Grafana:

- Go to **Connections** → **Data sources**
- Add **Prometheus**
- URL: `http://localhost:9090` (or your Prometheus host)
- Save & Test

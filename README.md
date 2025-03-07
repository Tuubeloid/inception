# 🚀 Inception VM Project Documentation

## 📌 Introduction
This project is designed to enhance system administration skills using Docker. Multiple Docker images will be virtualized within a VM, ensuring structured deployment, security, and modularity.

## 📜 Guidelines
- The project must be completed in a Virtual Machine (VM).
- All configuration files should be placed in `srcs/`.
- A `Makefile` must set up the application via `docker-compose.yml`.

## 🔧 Required Services
- **NGINX** (TLSv1.2/1.3 only, acts as the reverse proxy).
- **WordPress + PHP-FPM** (configured without NGINX, connects to MariaDB).
- **MariaDB** (Database for WordPress, separate from NGINX).
- **Volumes** for WordPress database and website files.
- **Docker Network** to securely link services.

## ⚠️ Constraints

![image](https://github.com/user-attachments/assets/a9b8682d-a87d-461f-b4d1-070b6d709526)

- Containers must auto-restart on failure.
- `network: host`, `--link`, and `links:` cannot be used.
- Avoid infinite loops (`tail -f`, `bash`, `sleep infinity`).
- The WordPress admin username **must not** contain `admin` or `administrator`.
- Volumes must be stored in `/home/data/`.
- The domain `.42.fr` must point to the local IP.
- **NGINX** must be the sole entry point via port `443` using **TLSv1.2/1.3**.

---

## 🖥 Virtual Machine Setup
### 🔹 Installing VirtualBox
- [Download VirtualBox](https://www.virtualbox.org/)
- [Download Alpine Linux](https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/x86_64/) (alpine-virt-3.20.4-x86_64.iso)

### 🔹 Virtual Machine Configuration
1. Open **VirtualBox** and create a new VM named `Inception`.
2. Set **folder location** to `goinfre` or your USB drive.
3. Select **ISO Image** (Alpine), **Type:** Linux, **Version:** Other Linux (64-bit).
4. Set **Base Memory** to `2048MB`, **Processors** to `1 CPU`.
5. Set **Virtual Hard Disk size** to `30GB`.
6. Click **Finish**.
7. Open **Settings** → **Storage** → **Optical Drive** → Select Alpine ISO.
8. Click **Start** and proceed with installation.

### 🔹 Setting Up Alpine Linux
1. **Login as** `root`.
2. Run `setup-alpine` and follow the prompts:
   - Keyboard Layout: `us`
   - Hostname: `tvalimak.42.fr`
   - Set up **password and timezone**.
   - Install to disk (`sda` → `sys` → `y`).
3. Remove the **installation disk** and reboot.
4. Login as `root` and set up `sudo`:
   ```sh
   vi /etc/apk/repositories  # Uncomment the last line
   apk update
   apk add sudo
   visudo  # Uncomment %sudo ALL=(ALL:ALL) ALL
   addgroup sudo
   adduser tvalimak sudo
   ```
5. **Configure SSH**:
   ```sh
   apk add nano openssh
   nano /etc/ssh/sshd_config
   ```
   - Uncomment `Port` and set it to `4241`.
   - Change `PermitRootLogin` to `no`.
   - Save and exit (`CTRL+O`, `Enter`, `CTRL+X`).
   ```sh
   rc-service sshd restart
   netstat -tuln | grep 4241  # Verify SSH is listening
   ```
6. **Set up SSH Port Forwarding in VirtualBox**:
   - Open **Settings** → **Network** → **Advanced** → **Port Forwarding**.
   - Add a rule: **Host Port** = `4241`, **Guest Port** = `4241`.
   - Click OK.
7. **Test SSH Connection**:
   ```sh
   ssh localhost -p 4241
   ```

---

## 🔑 Environment Variables (.env File)
```ini
DOMAIN_NAME=tvalimak.42.fr

SSL_CERT_PATH=/etc/ssl/certs/selfsigned.crt
SSL_KEY_PATH=/etc/ssl/private/selfsigned.key

WORDPRESS_DB_HOST=mariadb:3306

MYSQL_USER=tvalimak
MYSQL_PASSWORD=userpass
MYSQL_DATABASE=wordpress
MYSQL_ROOT_PASSWORD=rootpass
WORDPRESS_TITLE=Inception
WORDPRESS_ADMIN_USER=user666
WORDPRESS_ADMIN_PASSWORD=pass
WORDPRESS_ADMIN_EMAIL=admin666@gmail.com
WORDPRESS_USER=tvalimak
WORDPRESS_PASSWORD=pass
WORDPRESS_EMAIL=user666@gmail.com
```

---

## 🔥 Running the Project
```sh
cd ~/Inception/srcs
make
```
🚀 Your services should now be running inside Docker! 🎉

---








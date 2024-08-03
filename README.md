# cloudflare-ddns

# Cloudflare DDNS Update Script

This script updates the DNS record on Cloudflare if the current public IP address is different from the IP address registered in Cloudflare and the last recorded IP address. This is useful for keeping a dynamic IP address updated with a static DNS record.

## How It Works

1. The script fetches the current public IP address.
2. It reads the last recorded IP address from a local file (`last_ip.txt`).
3. If the current IP is different from the last recorded IP:
   - It checks the current IP address registered with Cloudflare.
   - If the current public IP is different from the Cloudflare IP, it updates the DNS record on Cloudflare.
   - It logs the update in `logs.txt` with a timestamp.
4. If the current IP is the same as the last recorded IP, no action is taken.

## Setup

1. **Clone this repository:**
   ```bash
   git clone https://github.com/jonaylton/cloudflare-ddns.git
   cd cloudflare-ddns
   ```

2. **Edit the script:**
   Open `cloudflare-ddns.sh` and replace the following placeholders with your actual Cloudflare API key, Zone ID, and DNS record name:
   ```bash
   CF_API_KEY="YOUR_API_KEY"
   ZONE_ID="YOUR_ZONE_ID"
   RECORD_NAME="A_DNS_RECORD"
   ```

3. **Set up environment variables (optional but recommended):**
   Create a file named `.env` in the same directory as the script and add your Cloudflare credentials:
   ```env
   CF_API_KEY=YOUR_API_KEY
   ZONE_ID=YOUR_API_KEY
   RECORD_NAME=YOUR_API_KEY
   ```

   Modify the script to load the environment variables:
   ```bash
   #!/bin/bash
   set -a
   source .env
   set +a
   ```

4. **Make the script executable:**
   ```bash
   chmod +x cloudflare-ddns.sh
   ```

5. **Set up a cron job to run the script periodically:**
   Open your crontab configuration:
   ```bash
   crontab -e
   ```

   Add the following line to run the script every minute (adjust the frequency as needed):
   ```bash
   * * * * * /path/to/cloudflare-ddns.sh >/dev/null 2>&1
   ```

## Logging

- The script logs updates in `logs.txt` with timestamps.
- The log includes the current IP, last recorded IP, and any updates made to the Cloudflare DNS record.

## Dependencies

- `curl`: Used to fetch the current public IP and interact with the Cloudflare API.
- `jq`: Used to parse JSON responses from the Cloudflare API.

You can install these dependencies using your package manager. For example, on Debian-based systems:
```bash
apt install curl jq
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contribution

Feel free to fork this repository and submit pull requests. Any improvements or bug fixes are welcome!

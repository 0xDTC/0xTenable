<a href="https://www.buymeacoffee.com/0xDTC"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a knowledge&emoji=📖&slug=0xDTC&button_colour=FF5F5F&font_colour=ffffff&font_family=Comic&outline_colour=000000&coffee_colour=FFDD00" /></a>

# 0xTenable

0xTenable is a collection of shell scripts designed to interact with Tenable's security platform, facilitating the automation of asset discovery and management tasks.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Fetch All New Identified Assets](#fetch-all-new-identified-assets)
  - [Fetch Discovered Assets](#fetch-discovered-assets)
- [Contributing](#contributing)
- [License](#license)

## Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/0xDTC/0xTenable.git
   cd 0xTenable
   ```

2. **Ensure the scripts have execute permissions:**

   ```bash
   chmod +x Fetch_all_new_identified_assets.sh
   chmod +x Fetch_discoverd_assets.sh
   ```

3. **Install necessary dependencies:**

   Ensure that `curl` and `jq` are installed on your system, as these scripts rely on them for HTTP requests and JSON parsing.

   - **For Debian/Ubuntu:**

     ```bash
     sudo apt-get install curl jq
     ```

   - **For CentOS/RHEL:**

     ```bash
     sudo yum install curl jq
     ```

   - **For macOS:**

     ```bash
     brew install curl jq
     ```

## Usage

Before running the scripts, ensure you have the necessary API credentials from your Tenable account and that you've set them as environment variables:

```bash
export TENABLE_ACCESS_KEY=your_access_key
export TENABLE_SECRET_KEY=your_secret_key
```

### Fetch All New Identified Assets

This script retrieves all newly identified assets from Tenable.

```bash
./Fetch_all_new_identified_assets.sh
```

**Expected Output:**

A JSON-formatted list of newly identified assets.

### Fetch Discovered Assets

This script fetches all discovered assets from Tenable.

```bash
./Fetch_discoverd_assets.sh
```

**Expected Output:**

A JSON-formatted list of discovered assets.

## Contributing

Contributions are welcome! Please follow these steps:

1. **Fork the repository.**
2. **Create a new branch:**

   ```bash
   git checkout -b feature/your_feature_name
   ```

3. **Commit your changes:**

   ```bash
   git commit -m 'Add some feature'
   ```

4. **Push to the branch:**

   ```bash
   git push origin feature/your_feature_name
   ```
5. **Open a pull request.**

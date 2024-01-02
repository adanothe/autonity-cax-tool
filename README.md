# Centralized Auton Exchange (CAX) Tools

This script provide to interact with the Centralized Auton Exchange (CAX) .

## Exchange Resources

- **CAX API URL:** [https://cax.piccadilly.autonity.org/api/](https://cax.piccadilly.autonity.org/api/)
- **Exchange Address:** 0x11F62c273dD23dbe4D1713C5629fc35713Aa5a94
- **API Docs:** [API Documentation](https://cax.piccadilly.autonity.org/docs)

## Prerequisites

Ensure the following dependencies are installed:

1. **jq**: JSON processor for bash
   ```bash
   apt install jq
   ```

2. **httpie**: Modern command-line HTTP client
   ```bash
   curl -SsL https://packages.httpie.io/deb/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/httpie.gpg
   sudo echo "deb [arch=amd64 signed-by=/usr/share/keyrings/httpie.gpg] https://packages.httpie.io/deb ./" > /etc/apt/sources.list.d/httpie.list
   sudo apt update
   sudo apt install httpie
   ```

## Quick Setup

1. Clone the CAX tool repository:
   ```bash
   git clone https://github.com/Dedenwrg/autonity-cax-tool.git
   cd autonity-cax-tool
   ```

2. Copy the default environment file:
   ```bash
   cp .env.default .env
   ```

3. Make the CAX script executable:
   ```bash
   chmod +x cax.sh
   chmod +x caxweb3.sh
   chmod +x get_aut_api_key
   ```
   
## Usage

Run the script using the following command:

#manual
```bash
./cax.sh
```
auto
```
./caxweb3.sh
```
The script provides the following options:

1. **Generate API Key**
2. **View Balance**
3. **View Order Books**
4. **Orderbook Information**
5. **Place Order**
6. **Check Open Order**
7. **Cancel Order**
8. **Withdraw**
9. **Check Deposits & Withdraw History**
10. **Exit**

Follow the prompts and input the required information for each action.

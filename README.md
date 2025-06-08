# 🛡️ FileGuard

**FileGuard** is a decentralized file storage and sharing system powered by **Ethereum smart contracts**. It supports subscription-based access with multiple **tiers and billing cycles**, allowing users to **upload, manage, and securely share encrypted files** on-chain with full transparency and control.

---

## 🚀 Features

- 🔐 **Subscription-Based Access**
  - Tiers: Free | Basic | Pro | Business
  - Billing: Monthly | Quarterly | Yearly

- 📂 **Decentralized File Management**
  - Upload and register files with metadata
  - Track usage and storage consumption

- 🔄 **Secure File Sharing**
  - Share file access with recipients via on-chain permissions and encrypted keys

- 💰 **Tokenized Payments**
  - Pay for subscriptions in ETH or FIL
  - Integrated with **Chainlink price feeds** for accurate USD to crypto conversion

- 🧠 **Smart Contract Controlled**
  - Built in **Solidity** with modular architecture for subscriptions, access control, and sharing logic

---

## 📦 Getting Started

### ✅ Prerequisites

- Node.js ≥ 16
- npm or yarn
- MetaMask wallet
- Hardhat (or Truffle)
- Web3.js or Ethers.js
- Infura or Alchemy API

---

### 🔧 Installation

```bash
git clone https://github.com/IamTamheedNazir/FileGuard.git
cd FileGuard
npm install
```

---

### 🛠 Deployment (Hardhat)

1. Set up your `.env` file:
   ```env
   PRIVATE_KEY=your_wallet_private_key
   INFURA_API_KEY=your_infura_project_id
   ```

2. Compile and deploy to Sepolia:
   ```bash
   npx hardhat compile
   npx hardhat run scripts/deploy.js --network sepolia
   ```

3. Copy the deployed contract address and ABI to your frontend config.

---

## 💡 Usage

### 📝 Subscribe to a Plan
- Choose your tier and billing cycle
- Submit the subscription via MetaMask

### 📤 Upload a File
- Provide the file hash and size
- Smart contract stores metadata with your subscription ID

### 🤝 Share a File
- Enter the file hash, recipient’s address, and encrypted access key
- The recipient can retrieve and decrypt the file via smart contract query

---

## 🌐 Tech Stack

- **Solidity** – Smart contracts for subscription & sharing logic
- **Chainlink** – Price feed integration for real-time crypto rates
- **Hardhat** – Development and deployment
- **IPFS** *(Planned)* – Off-chain storage backend
- **React + Ethers.js** *(Frontend, Optional)* – Web3 integration for user interaction

---

## 🧩 Project Structure

```bash
FileGuard/
├── contracts/            # Smart contract files (Solidity)
├── scripts/              # Deployment scripts
├── test/                 # Contract test cases
├── frontend/             # React-based Web3 UI (optional)
├── .env                  # Environment variables (ignored)
├── hardhat.config.js     # Hardhat config
├── README.md             # This documentation
```

---

## 🤝 Contributing

We welcome contributions from the community!

- Fork the repository
- Create a new branch
- Submit a pull request with changes

Before contributing, please check the [CONTRIBUTING.md](CONTRIBUTING.md) (coming soon).

---

## 📜 License

This project is licensed under the **MIT License**.  
See the [LICENSE](LICENSE) file for more information.

---

## 📬 Contact

Created with ❤️ by **Tamheed Nazir**  
📧 Email: [tamheednazir1@gmail.com](mailto:tamheednazir1@gmail.com)  
🔗 GitHub: [@IamTamheedNazir](https://github.com/IamTamheedNazir)

A Clarity smart contract that issues **non-transferable ("soulbound") membership NFTs**. Each token represents a unique member and includes metadata such as username, role, and the block height at which they joined.

---

## 🚀 Features

- ✅ **Soulbound NFT**: Non-transferable membership tokens (can't be sent or traded).
- 👤 **Owner-Only Minting**: Only the contract owner can mint new tokens.
- 🗂 **Member Metadata**: Stores `username`, `role`, and `joined-at` for each token.
- 🔍 **Read-Only Access**: Query functions to check ownership, token details, and token supply.

---

## 📄 Contract Overview

| Function | Type | Description |
|----------|------|-------------|
| `mint-membership(recipient, username, role)` | public | Mint a new membership token to a given principal (owner only). |
| `transfer(token-id, sender, recipient)` | public | Always fails — ensures tokens are soulbound. |
| `get-member-details(token-id)` | read-only | Returns metadata for a given token ID. |
| `get-owner(token-id)` | read-only | Returns the owner of a specific token. |
| `get-last-token-id()` | read-only | Returns the last minted token ID. |

---

## 🧠 Data Structures

### 📦 Token
- Non-fungible token: `membership-nft`
- Token ID: `uint`

### 🗃 Member Metadata
Stored in a map `member-metadata`:
{
  username: (string-ascii 32),
  role: (string-ascii 32),
  joined-at: uint
}
⚠️ Errors
Constant	Code	Description
ERR-NOT-AUTHORIZED	err u100	Caller is not authorized to perform the action.
ERR-TRANSFER-BLOCKED	err u101	Transfers are permanently blocked (soulbound).
ERR-MEMBER-NOT-FOUND	err u102	No member metadata found for given token ID.

🔐 Access Control
contract-owner: Set on contract deploy (tx-sender).

Only the contract-owner can mint new membership NFTs.

🛠 Usage Example
Mint a New Member
(mint-membership 'SP123... "alice" "admin")
Get Member Details
(get-member-details u1)
Get Token Owner
clarity
Copy code
(get-owner u1)

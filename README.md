# Solana-Flutter-DeFi-SDK

![image](https://user-images.githubusercontent.com/13432688/188311135-13376bba-bceb-489c-8c5c-f4bec1055365.png)

## Solana Wallet

Build the wallet module on the basis of [cryptoplease-dart](https://github.com/cryptoplease/cryptoplease-dart)

- Borsh
- Crypto Please
  - Send Crypto with just a link
  - Create a new wallet
  - Import your existing wallet by typing your recovery phrase (12 words or 24 words)
  - Send and Receive SOL Token
  - Send and Receive SPL Tokens like USDT, USDC
  - History of transactions
- JSON rpc_client
- Dart library for Solana
  - Complete implementation of the JSON RPC api.
  - Complete implementation of a subscription client (using the JSON RPC subscription variant of the API).
  - Complete implementation of the following programs
    - System Program
    - Token Program
    - Memo Program
    - Stake Program
    - Associated Token Account Program
  - Support for key generation/importing using Hierarchical Deterministic derivation.
  - Support for importing keys by using a bip39 seed phrase.
  - Support for importing keys by using raw private key bytes.
  - Transaction encoding and signing.
  - Building and signing offline transactions, as well as convenience methods to sign and send the transaction. Also, the ability to listen for a status change on a given signature. The latter can be used to wait for a transaction to be in the confirmed or finalized state.
  - Support for decoding Metaplex NFT metadata.

## NFT Dating APP

### Chat

Used [google messages](https://messages.google.com/)

- Message text
- Message image
- Audio call
- Video call

### Location

Used [google maps](https://www.google.com/maps)

### Storage

Used [google firestore](https://firebase.google.com/docs/firestore)

### Monitor

Used [sentry api](https://sentry.io/)

### Swap

Used [jupiter api](https://jup.ag/)

### Cross chain

Used [canoe wormhole](https://github.com/Canoe-Finance/wormhole-node)

Send request http, and get the base64 transaction data, then send to blockchain. [More info](https://github.com/Canoe-Finance/wormhole-node)

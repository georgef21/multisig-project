# Multisig Wallet Deployment with Hardhat

This project demonstrates the deployment and interaction with a multisig wallet on a local blockchain using Hardhat.

## Prerequisites
Ensure you have the following installed:
- [Node.js](https://nodejs.org/) (Latest LTS version recommended)
- [npm](https://www.npmjs.com/) (Comes with Node.js)
- [Hardhat](https://hardhat.org/)

## Clone the Repository
First, clone this repository and navigate into the project directory:
```sh
git clone <repository_url>
cd <repository_name>
```

## Installation

Before proceeding, remove existing dependencies and clear npm cache:

```sh
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```
Verify that Hardhat is installed:
```sh
npx hardhat --version
```
If you encounter an error, install Hardhat as a development dependency:
```sh
npm install --save-dev hardhat
```

## Running a Local Blockchain
Start a Hardhat local blockchain in a new terminal session:
```sh
npx hardhat node
```
This will launch a local Ethereum network, simulating a blockchain environment.

## Deploying the Multisig Wallet
In the original terminal session, deploy the multisig wallet contract:
```sh
npx hardhat run scripts/deploy.js --network localhost
```
Monitor the local blockchain (in the other terminal) for new blocks as transactions are executed.

## Submitting and Executing Transactions

To interact with the multisig wallet, run the following scripts in order(avoid running them all at the sametime:
```sh
npx hardhat run scripts/submitTx.js --network localhost
npx hardhat run scripts/approve.js --network localhost
npx hardhat run scripts/executeTx.js --network localhost
```

## Updating Signers in the Multisig Wallet
If you need to update the signers, execute the following scripts (in order not all at once):
```sh
npx hardhat run scripts/proposeSignerUpdate.js --network localhost
npx hardhat run scripts/approveSignerUpdate.js --network localhost
npx hardhat run scripts/executeSignerUpdate.js --network localhost
```

## Notes

1. Ensure your Hardhat node is running in a seperate shell tab before executing any scripts. 
2. Ensure you are performing these commands in the directory of the cloned repo
3. You need to have 2 shell tabs opened ( one for seeing blocks getting added to the local blockchain netwrok , one for running the scripts )
4. this smart contract is designed to only be run locally as it's logic is not audited for advanced securty considerations and no advanced signer logic implemented.


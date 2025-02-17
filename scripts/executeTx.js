const { ethers } = require("hardhat");

async function main() {
    const [owner, signer1, signer2, signer3] = await ethers.getSigners();

    const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";  // Replace with your actual deployed contract address
    const multisig = await ethers.getContractAt("MultisigWallet", contractAddress);

    const txId = 0; // Transaction ID to execute (0 for the first transaction)

    await multisig.connect(signer3).executeTransaction(txId);
    console.log("Transaction executed successfully!");
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});

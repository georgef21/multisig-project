const { ethers } = require("hardhat");

async function main() {
    const [owner, signer1] = await ethers.getSigners();

    const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3"; // Replace with your actual deployed contract address
    const multisig = await ethers.getContractAt("MultisigWallet", contractAddress);

    const updateId = 0; // Replace with the ID of the proposed update

    await multisig.connect(signer1).executeSignerUpdate(updateId);
    console.log("Signer update executed successfully!");
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
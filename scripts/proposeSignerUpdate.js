const { ethers } = require("hardhat");

async function main() {
    const [owner, signer1] = await ethers.getSigners();

    const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3"; // Replace with your actual deployed contract address
    const multisig = await ethers.getContractAt("MultisigWallet", contractAddress);

    const newSigners = [signer1.address, "0xBcd4042DE499D14e55001CcbB24a551F3b954096", "0x71bE63f3384f5fb98995898A86B02Fb2426c5788"]; // Replace with new signer addresses
    const newRequiredSignatures = 2; // Replace with new required signatures

    const tx = await multisig.connect(signer1).proposeSignerUpdate(newSigners, newRequiredSignatures);
    await tx.wait();

    console.log("Signer update proposed successfully!");
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
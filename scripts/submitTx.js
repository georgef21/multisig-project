const hre = require("hardhat");

async function main() {
    const [_, signer1] = await hre.ethers.getSigners();
    const walletAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
    const wallet = await hre.ethers.getContractAt("MultisigWallet", walletAddress);

    const tx = await wallet.connect(signer1).submitTransaction(
        "0x0000000000000000000000000000000000000000", 0, "0x"
    );
    await tx.wait();

    console.log("Transaction submitted successfully.");
}

main();

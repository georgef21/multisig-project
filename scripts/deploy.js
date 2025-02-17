const hre = require("hardhat");

async function main() {
    const [deployer, signer1, signer2, signer3] = await hre.ethers.getSigners();
    
    console.log(`Deploying contracts with the account: ${deployer.address}`);

    const MultisigWallet = await hre.ethers.getContractFactory("MultisigWallet");
    const signers = [signer1.address, signer2.address, signer3.address];
    const requiredSignatures = 2;

    const wallet = await MultisigWallet.deploy(signers, requiredSignatures);
    await wallet.waitForDeployment();

    console.log(`Multisig Wallet deployed at: ${await wallet.getAddress()}`);
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});

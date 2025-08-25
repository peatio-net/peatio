const fs = require("fs");
const ethers = require("ethers");

async function createWallet(password) {
  const wallet = ethers.Wallet.createRandom();
  const keystore = await wallet.encrypt(password);

  const output = {
    address: wallet.address,
    privateKey: wallet.privateKey,
    keystore: keystore
  };

  console.log(JSON.stringify(output));
}

const password = process.argv[2] || "default-password";
createWallet(password);

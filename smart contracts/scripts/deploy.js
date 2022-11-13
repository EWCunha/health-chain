const hre = require("hardhat");
const fs = require('fs');

async function main(deploy = true) {

  let management
  if (deploy) {
    const Management = await hre.ethers.getContractFactory("Management");
    management = await Management.deploy();

    await management.deployed();

    let trial = 1
    while (true) {
      try {
        await hre.run("verify:verify", {
          address: management.address,
          constructorArguments: [],
        });
        break
      } catch (e) {
        if (e.message.includes("Already Verified")) {
          break
        }
        console.log(`Trial ${trial}`)
        trial++
      }
    }
  } else {
    management = require("../../frontend/src/contracts/Management.json")
  }

  const management_json = require("../artifacts/contracts/Management.sol/Management.json")
  const medHistory_json = require("../artifacts/contracts/MedicalHistory.sol/MedicalHistory.json")

  const management_contract_obj = { address: management.address, abi: management_json.abi }
  const medHistory_contract_obj = { address: "", abi: medHistory_json.abi }

  fs.writeFile("../frontend/src/contracts/Management.json", JSON.stringify(management_contract_obj), function (err) {
    if (err) throw err;
    console.log('complete Management');
  }
  )

  fs.writeFile("../frontend/src/contracts/MedicalHistory.json", JSON.stringify(medHistory_contract_obj), function (err) {
    if (err) throw err;
    console.log('complete MedicalHistory');
  }
  )

  console.log("Deployed at:", management.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
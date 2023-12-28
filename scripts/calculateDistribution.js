const { program } = require('commander')
const fs = require("fs")
const ethers = require("ethers")

program.option('-f, --file <path>', "route to the file with the allowlist addresses","./delegationData.json")
program.parse()

const options = program.opts()
const delegation_data = require(options.file)
const TOTAL_CTX_REWARD = 50000

function main() {
   let total_weight = 0;
   let distribution_data = [];
   let sum = 0
    for (const key in delegation_data) {
        const delegation = delegation_data[key];
        total_weight += delegation.days * delegation.amount * delegation.participation
    }
    for (const key in delegation_data) {
        const delegation = delegation_data[key];
        const ctx_reward = (delegation.days * delegation.amount * delegation.participation * TOTAL_CTX_REWARD) / total_weight
        distribution_data.push([delegation.address, ethers.parseEther(ctx_reward.toString()).toString()])
    }
    fs.writeFileSync("distribution.json", JSON.stringify(distribution_data));
}

main()
console.log("distribution.json file created sucessfully");

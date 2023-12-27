const { program } = require('commander')
const fs = require("fs")

program.option('-f, --file <path>', "route to the file with the allowlist addresses","./delegationData")
program.parse()

const options = program.opts()
const delegation_data = require(options.file).default

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
        distribution_data.push({address:delegation.address, amount: ctx_reward})
    }
    fs.writeFileSync("test.json", JSON.stringify(distribution_data));
}

main()

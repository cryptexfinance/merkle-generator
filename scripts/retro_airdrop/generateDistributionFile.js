const { StandardMerkleTree } = require('@openzeppelin/merkle-tree');
const keccak256 = require('keccak256');
const fs = require("fs");


const tree = StandardMerkleTree.load(JSON.parse(fs.readFileSync("tree.json", "utf8")));
let data = {}

for (const [i, v] of tree.entries()) {
    data[v[0]] = {
        amount: v[1],
        proof: tree.getProof(i)
    }
}

fs.writeFileSync("finalDistribution.json", JSON.stringify(data,  null, "\t"));

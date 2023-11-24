const { StandardMerkleTree } = require('@openzeppelin/merkle-tree');
const keccak256 = require('keccak256');
const fs = require("fs");

// (1)
const tree = StandardMerkleTree.load(JSON.parse(fs.readFileSync("tree.json", "utf8")));

// (2)
for (const [i, v] of tree.entries()) {
  if (v[0] === '0x097a3a6ce1d77a11bda1ac40c08fdf9f6202103f') {
    // (3)
    const proof = tree.getProof(i);
    console.log('Value:', v);
    console.log('Proof:', proof);
  }
}

const { StandardMerkleTree } = require('@openzeppelin/merkle-tree');
const keccak256 = require('keccak256');
const fs = require("fs");

// (1)
const tree = StandardMerkleTree.load(JSON.parse(fs.readFileSync("tree.json", "utf8")));
console.log(tree.root);
// (2)
for (const [i, v] of tree.entries()) {
  if (v[0] === '0x8540F80Fab2AFCAe8d8FD6b1557B1Cf943A0999b') {
    // (3)
    const proof = tree.getProof(i);
    console.log('Value:', v);
    console.log('Proof:', proof);
  }
}

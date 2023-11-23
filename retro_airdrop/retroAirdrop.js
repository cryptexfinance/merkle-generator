const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');


const whitelistAddresses = require("./example").default;
// console.log(whitelistAddresses);

function createMerkleRoot() {
    const leafNodes = whitelistAddresses.map(row => (keccak256(["address", "uint256"], row.address, row.earnings)));
    const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });
    const merkleRoot = merkleTree.getHexRoot();
    const proof = merkleTree.getProof(leafNodes[0]);
    console.log(merkleTree.toString());
    console.log('merkle root:', merkleRoot);
    console.log('leaf 0', merkleTree.getHexProof(leafNodes[0]));
    console.log(merkleTree.verify(proof, leafNodes[0], merkleRoot)) // true
    // console.log('leaf 2', merkleTree.getHexProof(leafNodes[2]));
    // console.log('leaf 1', merkleTree.leafNodes[1]);
}

createMerkleRoot();

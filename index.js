const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');


const whitelistAddresses = require("./whitelistTestnet").default;
// console.log(whitelistAddresses);

function createMerkleRoot() {
    const leafNodes = whitelistAddresses.map(addr => keccak256(addr));
    const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });
    const merkleRoot = merkleTree.getHexRoot();
    console.log('merkle root:', merkleRoot);
    // console.log('leaf 1', merkleTree.getHexProof(leafNodes[0]));
    // console.log('leaf 2', merkleTree.getHexProof(leafNodes[2]));
    // console.log('leaf 1', merkleTree.leafNodes[1]);
}

createMerkleRoot();

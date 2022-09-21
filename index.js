const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');

let whitelistAddresses = [
    "0x9D1A807355056442F878F3bBC22054a0677e7995", "0xd4fa23307a181B9ca567886eB5bCd5c8f8f8bB3E", "0x484624a2e0Ea9D1AE01Ad4EFDD7B52F83329f3c7", "0x9D1A807355056442F878F3bBC22054a0677e7995", "0xd4fa23307a181B9ca567886eB5bCd5c8f8f8bB3E", "0x484624a2e0Ea9D1AE01Ad4EFDD7B52F83329f3c7", "0x9D1A807355056442F878F3bBC22054a0677e7995", "0xd4fa23307a181B9ca567886eB5bCd5c8f8f8bB3E", "0x484624a2e0Ea9D1AE01Ad4EFDD7B52F83329f3c7", "0x9D1A807355056442F878F3bBC22054a0677e7995", "0xd4fa23307a181B9ca567886eB5bCd5c8f8f8bB3E", "0x484624a2e0Ea9D1AE01Ad4EFDD7B52F83329f3c7", "0x9D1A807355056442F878F3bBC22054a0677e7995", "0xd4fa23307a181B9ca567886eB5bCd5c8f8f8bB3E", "0x484624a2e0Ea9D1AE01Ad4EFDD7B52F83329f3c7", "0x9D1A807355056442F878F3bBC22054a0677e7995", "0xd4fa23307a181B9ca567886eB5bCd5c8f8f8bB3E", "0x484624a2e0Ea9D1AE01Ad4EFDD7B52F83329f3c7", "0x9D1A807355056442F878F3bBC22054a0677e7995", "0xd4fa23307a181B9ca567886eB5bCd5c8f8f8bB3E", "0x484624a2e0Ea9D1AE01Ad4EFDD7B52F83329f3c7", "0x9D1A807355056442F878F3bBC22054a0677e7995", "0xd4fa23307a181B9ca567886eB5bCd5c8f8f8bB3E", "0x484624a2e0Ea9D1AE01Ad4EFDD7B52F83329f3c7"
];

function createMerkleRoot() {
    const leafNodes = whitelistAddresses.map(addr => keccak256(addr));
    const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });
    const merkleRoot = merkleTree.getHexRoot();
    console.log('merkle tree', merkleTree.toString());
    console.log('merkle root:', merkleRoot);
    console.log('leaf 1', merkleTree.getHexProof(leafNodes[2]));

    // console.log('leaf 1', merkleTree.leafNodes[1]);
}

createMerkleRoot();

# Merkle Generator

Scripts to generate merkle roots for inclusions in a list, can be used for airdrops or claims if an address is included. This repo has the script for multiple merkles in the Cryptex Ecosystem.

### Governance Retroactive Airdrop

This script generates the merkle root for the distribution of the retroactive CTX airdrop for Cryptex users that engaged in governbnace. The distribution amount is 50k CTX as approved by the [DAO here](https://forum.cryptex.finance/t/align-single-sided-staking-rewards/374). Here are the rules of elegibility and distribution:

- Snapshot date is 1 October 2023, a few weeks before the initial discussion.
- Airdrop takes into account the CTX delegated for governance including staked on Single Side Staking.
- Airdrop Multipliers are based in the number of month.
- Airdrop is has a multiplier calculated based on participation in governance of the delegate onchain.

## How to use

#### calculateDistribution

This scripts takes a json file with the data of delegation to calculate how much each address should get.

```bash
node calculateDistribution -f <FILE_OF_ALLOWLIST>
```

#### generateTree

This will print the merkleroot used in the claim contracts.

```bash
node generateTree -f <FILE_OF_ALLOWLIST>
```

#### obtainProof

You can edit and use the `obtainProof` script to get a proof for an address which can be used to make a claim.

```bash
node obtainProof
```

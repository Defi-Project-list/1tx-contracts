# 1tx network

> Simplifying complicated DeFi workflows into a single click

1tx streamlines Web3 interactions, replacing manual complexity with seamless 1-click execution. Users effortlessly orchestrate on-chain workflows and execute customized protocol interactions. Unlike traditional vaults, where custody is relinquished, 1tx empowers users to retain full control of their assets while ensuring complete transparency. Additionally, 1tx introduces a social dimension by empowering users to access and replicate the latest DeFi strategies from prominent figures in the crypto community, such as whales, OG traders, and KOLs.

## Contracts

### Executor

Executor is the main contract that sequentially executes the recipe. It is registered as a plugin in the user's SCA, and all actions are executed within the user SCA context.

### Registry

Registry collects the addresses of contracts deployed by 1tx. Since it uses the contract name to look up addresses, all action contracts are upgradable.

### RecipeStorage

At 1tx, anyone can create their own 1tx strategies.
The strategies created by users are stored in RecipeStorage and recorded on-chain.

### Action Contract

This represents the smallest unit of action in a recipe process. Actions such as SingleSwap, FlashLoan, Wrapping, etc., are written in the smallest units, allowing recipe creators to arrange and customize actions as desired.

## Installation

```
// If you haven't installed Rust yet
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

// If you haven't installed Foundry
curl -L https://foundry.paradigm.xyz | bash

// If you haven't installed ethabi
cargo install ethabi-cli

// Getting Started
forge install
forge build
```

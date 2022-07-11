require("@nomiclabs/hardhat-waffle");
require('@openzeppelin/hardhat-upgrades');
require("@nomiclabs/hardhat-etherscan");
require("hardhat-tracer");
require("hardhat-gas-reporter");

module.exports = {
    solidity: {
        compilers: [
            {
                version: "0.8.9",
                settings: {
                    optimizer: { // Keeps the amount of gas used in check
                        enabled: true,
                        runs: 1000
                    }
                }
            }
        ]
    },
    gasReporter: {
        currency: 'USD',
        gasPrice: 21,
        coinmarketcap: "9896bb6e-1429-4e65-8ba8-eb45302f849b",
        showMethodSig: true,
        showTimeSpent: true,
    },
    etherscan: { 
        apiKey: 'TZIQBTY59K1JUJUH22DKBUF9KDK65N57DN'
    },
    networks: {
        hardhat: {
            chainId: 31337,
            gas: "auto",
            gasPrice: "auto",
            saveDeployments: false,
        }
    },
};
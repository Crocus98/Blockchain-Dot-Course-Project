module.exports = {
  contracts_directory: "SmartContracts/",
  contracts_build_directory: "SmartContracts/contracts",
  compilers: {
    solc: {
      version: ">=0.7.0 <0.9.0",
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};

var Clp = artifacts.require("./Token.sol");

module.exports = function(deployer, accounts) {
	deployer.deploy(
		Clp, "Clp", "CLP", 18, 140000000000000000000, 
		{from: accounts[1]}
		);
};

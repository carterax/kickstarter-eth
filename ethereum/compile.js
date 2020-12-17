const path = require('path');
const solc = require('solc');
const fs = require('fs-extra');

// get the build path
const buildPath = path.resolve(__dirname, 'build');

// check if build folder exists
// if it does delete it
fs.removeSync(buildPath);

// compile the campaign contract
// from the contract source
// after compilation we get an ABI
// and ByteCode
const campaignPath = path.resolve(__dirname, 'contracts', 'Campaign.sol');
const source = fs.readFileSync(campaignPath, 'utf8');
const output = solc.compile(source, 1).contracts;

// create the build folder
fs.ensureDirSync(buildPath);

// loop through the returned compiled contract output
// and write them to the build folder
for (let contract in output) {
	fs.outputJsonSync(
		path.resolve(buildPath, contract.replace(':', '') + '.json'),
		output[contract]
	);
}

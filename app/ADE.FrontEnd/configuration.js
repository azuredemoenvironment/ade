const { AppConfigurationClient } = require('@azure/app-configuration');
const fs = require('fs');

const connectionString = process.env.CONNECTIONSTRINGS__APPCONFIG;
const adeEnvironment = process.env.ADE__ENVIRONMENT;

const client = new AppConfigurationClient(connectionString);

// Manually specify keys to retrieve, we don't want protected configuration to be written to a publicly accessible file
const keysToRetrieve = [
	'ADE:ApiGatewayUri',
	'AppInsights:ConnectionString',
	'AppInsights:InstrumentationKey'
];
const outputFileName = '.env';
const outputFileStream = fs.createWriteStream(outputFileName, { flags: 'w' });

async function run() {
	for (let index = 0; index < keysToRetrieve.length; index++) {
		const key = keysToRetrieve[index];
		const retrievedKey = await client.getConfigurationSetting({
			key,
			label: `%00,${adeEnvironment}`
		});

		// Change key to be envar-friendly
		const modifiedKey = key.replace(':', '__').toUpperCase();

		outputFileStream.write(`${modifiedKey}=${retrievedKey.value}\n`);
	}
}

run().catch((err) => console.log('ERROR:', err));

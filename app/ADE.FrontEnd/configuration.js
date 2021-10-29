const { AppConfigurationClient } = require('@azure/app-configuration');
const fs = require('fs');

const connectionString = process.env.CONNECTIONSTRINGS__APPCONFIG;
const adeEnvironment = process.env.ADE__ENVIRONMENT;

console.log(`Connecting to App Configuration service at ${connectionString}`);
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
		let retrievedKeyNoLabel, retrievedKeyWithLabel;

		console.log(`Retrieving key "${key}" with no label.`);
		try {
			retrievedKeyNoLabel = await client.getConfigurationSetting({
				key,
				label: '\0'
			});
		} catch {
			console.log(`Could not find key "${key}" with no label.`);
		}

		console.log(`Retrieving key "${key}" with a label of "${adeEnvironment}".`);
		try {
			retrievedKeyWithLabel = await client.getConfigurationSetting({
				key,
				label: adeEnvironment
			});
		} catch {
			console.log(
				`Could not find key "${key}" with a label of "${adeEnvironment}".`
			);
		}

		console.log('Keys retrieved:', retrievedKeyNoLabel, retrievedKeyWithLabel);

		const retrievedKey = retrievedKeyWithLabel || retrievedKeyNoLabel;

		// Change key to be envar-friendly
		const modifiedKey = key.replace(':', '__').toUpperCase();

		const envEntry = `${modifiedKey}=${retrievedKey.value}\n`;

		console.log(`Setting environment value: ${envEntry}`);
		outputFileStream.write(`${envEntry}\n`);
	}
}

run().catch((err) => console.log('ERROR:', err));

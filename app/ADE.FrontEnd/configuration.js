const { AppConfigurationClient } = require("@azure/app-configuration");
const fs = require("fs");

const connectionString = process.env.CONNECTIONSTRINGS__APPCONFIG;

const client = new AppConfigurationClient(connectionString);

// Manually specify keys to retrieve, we don't want protected configuration to be written to a publicly accessible file
const keysToRetrieve = [
  "ADE__APIGATEWAYURI",
  "APPINSIGHTS_CONNECTIONSTRING",
  "APPINSIGHTS_INSTRUMENTATIONKEY",
];
const outputFileName = ".env";
const outputFileStream = fs.createWriteStream(outputFileName, { flags: "w" });

async function run() {
  for (let index = 0; index < keysToRetrieve.length; index++) {
    const key = keysToRetrieve[index];
    const retrievedKey = await client.getConfigurationSetting({ key });
    outputFileStream.write(`${key}=${retrievedKey.value}` + "\n");
  }
}

run().catch((err) => console.log("ERROR:", err));

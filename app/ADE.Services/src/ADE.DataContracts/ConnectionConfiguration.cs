namespace ADE.DataContracts
{
    public class ConnectionConfiguration
    {
        public const string APPSETTINGS_ROOT_KEY = "Connections";

        public string ApiGatewayUri { get; set; }

        public string BlobStorageConnectionString { get; set; }

        public string CosmosDbConnectionString { get; set; }

        public string DataIngestorServiceUri { get; set; }

        public string DataReporterServiceUri { get; set; }

        public string MariaDbConnectionString { get; set; }

        public string PostgreSqlConnectionString { get; set; }

        public string SqlServerConnectionString { get; set; }

        public string UserServiceUri { get; set; }
    }
}
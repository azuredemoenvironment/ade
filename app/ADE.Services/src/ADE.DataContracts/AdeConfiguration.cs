namespace ADE.DataContracts
{
    public class AdeConfiguration
    {
        public const string APPSETTINGS_ROOT_KEY = "ADE";

        public string ApiGatewayUri { get; set; }

        public string AppConfig { get; set; }

        public string ApplicationInsights { get; set; }

        public string BlobStorageConnectionString { get; set; }

        public string CosmosDbConnectionString { get; set; }

        public string DataIngestorServiceUri { get; set; }

        public string DataReporterServiceUri { get; set; }

        public string EventHubConnectionString { get; set; }

        public string EventHubName { get; set; }

        public string EventIngestorServiceUri { get; set; }

        public string MariaDbConnectionString { get; set; }

        public string PostgreSqlConnectionString { get; set; }

        public string SqlServerConnectionString { get; set; }

        public string UserServiceUri { get; set; }
    }
}
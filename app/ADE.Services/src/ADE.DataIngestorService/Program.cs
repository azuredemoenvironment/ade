using ADE.ServiceBase;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;

namespace ADE.DataIngestorService
{
    public static class Program
    {
        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.ConfigureAppConfiguration(config =>
                    {
                        var settings = config.Build();
                        var connection = settings.GetConnectionString("AppConfig");
                        if(!string.IsNullOrWhiteSpace(connection))
                        {
                            config.AddAzureAppConfiguration(connection, true);
                        }
                    }).UseStartup<Startup>();
                });

        public static void Main(string[] args) =>
            CreateHostBuilder(args)
                .Build()
                .InitializationDatabases()
                .Run();
    }
}
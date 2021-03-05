using ADE.ServiceBase;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;

namespace ADE.DataIngestorService
{
    public static class Program
    {
        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                });

        public static void Main(string[] args) =>
            CreateHostBuilder(args)
                .Build()
                .InitializationDatabases()
                .Run();
    }
}
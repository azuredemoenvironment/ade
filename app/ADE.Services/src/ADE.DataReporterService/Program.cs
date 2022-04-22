using ADE.ServiceBase;
using Microsoft.Extensions.Hosting;

namespace ADE.DataReporterService
{
    public static class Program
    {
        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureAdeWebHostDefaults<Startup>();

        public static void Main(string[] args) =>
            CreateHostBuilder(args)
                .Build()
                .InitializationDatabases()
                .Run();
    }
}
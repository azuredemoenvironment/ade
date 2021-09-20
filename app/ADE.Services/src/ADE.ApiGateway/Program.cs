using ADE.ServiceBase;
using Microsoft.Extensions.Hosting;

namespace ADE.ApiGateway
{
    public class Program
    {
        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureAdeWebHostDefaults<Startup>();

        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }
    }
}
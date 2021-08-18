using Microsoft.Extensions.Hosting;

namespace ADE.EventDispatcher
{
    public class Program
    {
        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureFunctionsWorkerDefaults();

        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }
    }
}
using System;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;

namespace ADE.ApiGateway
{
    public class Program
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
                            config.AddAzureAppConfiguration(options =>
                            {
                                options.Connect(connection)
                                    .ConfigureRefresh(refresh =>
                                    {
                                        refresh.Register("ADE:Sentinel", true)
                                            .SetCacheExpiration(new TimeSpan(0, 5, 0));
                                    });
                            }, true);
                        }
                    }).UseStartup<Startup>();
                });

        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }
    }
}
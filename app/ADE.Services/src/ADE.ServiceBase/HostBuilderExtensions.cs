using System;
using ADE.DataAccess.SqlDatabase;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Configuration.AzureAppConfiguration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace ADE.ServiceBase
{
    public static class HostBuilderExtensions
    {
        public static IHostBuilder ConfigureAdeWebHostDefaults<TStartup>(this IHostBuilder hostBuilder) where TStartup : class
        {
            return hostBuilder.ConfigureWebHostDefaults(webBuilder =>
            {
                webBuilder.ConfigureAppConfiguration(config =>
                {
                    var settings = config.Build();
                    var connection = settings.GetConnectionString("AppConfig");
                    var adeEnvironment = settings.GetValue<string>("ADE:Environment");
                    if(!string.IsNullOrWhiteSpace(connection))
                    {
                        config.AddAzureAppConfiguration(options =>
                        {
                            options.Connect(connection)
                                .ConfigureRefresh(refresh =>
                                {
                                    refresh.Register("ADE:Sentinel", true)
                                        .SetCacheExpiration(new TimeSpan(0, 5, 0));
                                }).Select(KeyFilter.Any)
                                .Select(KeyFilter.Any, adeEnvironment);
                        }, true);
                    }
                }).UseStartup<TStartup>();
            });
        }

        public static IHost InitializationDatabases(this IHost host)
        {
            using var scope = host.Services.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<AdeDataContext>();
            db.Database.Migrate();

            return host;
        }
    }
}
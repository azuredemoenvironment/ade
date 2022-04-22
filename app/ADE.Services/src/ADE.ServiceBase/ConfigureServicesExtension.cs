using ADE.DataAccess.SqlDatabase;
using ADE.DataContracts;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace ADE.ServiceBase
{
    public static class ConfigureServicesExtension
    {
        public static IServiceCollection AddAdeConfiguration(this IServiceCollection services, IConfiguration configuration)
        {
            var adeConfiguration = new AdeConfiguration();
            configuration.GetSection(AdeConfiguration.APPSETTINGS_ROOT_KEY).Bind(adeConfiguration);
            adeConfiguration.AppConfig = configuration.GetConnectionString("AppConfig");
            adeConfiguration.ApplicationInsights = configuration.GetValue<string>("ApplicationInsights:ConnectionString");

            services.AddSingleton(adeConfiguration);
            return services;
        }

        public static IServiceCollection AddDataServices(this IServiceCollection services)
        {
            services.AddDbContext<AdeDataContext>();

            return services;
        }
    }
}
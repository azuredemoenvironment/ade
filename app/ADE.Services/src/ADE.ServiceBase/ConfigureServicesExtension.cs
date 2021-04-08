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
            var connectionConfiguration = new ConnectionConfiguration();
            configuration.GetSection(ConnectionConfiguration.APPSETTINGS_ROOT_KEY).Bind(connectionConfiguration);

            services.AddSingleton(connectionConfiguration);
            return services;
        }

        public static IServiceCollection AddDataServices(this IServiceCollection services)
        {
            services.AddDbContext<AdeDataContext>();

            return services;
        }
    }
}
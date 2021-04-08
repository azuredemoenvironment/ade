using ADE.DataAccess.SqlDatabase;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace ADE.ServiceBase
{
    public static class HostBuilderExtensions
    {
        public static IHost InitializationDatabases(this IHost host)
        {
            using var scope = host.Services.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<AdeDataContext>();
            db.Database.Migrate();

            return host;
        }
    }
}
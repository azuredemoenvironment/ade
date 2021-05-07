using ADE.DataContracts;
using Microsoft.EntityFrameworkCore;

namespace ADE.DataAccess.SqlDatabase
{
    public class AdeDataContext : DbContext
    {
        private readonly string _connectionString;

        public AdeDataContext(AdeConfiguration adeConfiguration)
        {
            _connectionString = adeConfiguration.SqlServerConnectionString;
        }

        public DbSet<UserDataPoint> UserDataPoints { get; set; }

        #region Overrides of DbContext

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            optionsBuilder.UseSqlServer(_connectionString, x => x.MigrationsAssembly("ADE.DataAccess"));
        }

        #endregion
    }
}
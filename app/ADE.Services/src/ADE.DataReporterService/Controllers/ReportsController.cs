using System.Collections.Generic;
using System.Threading.Tasks;
using ADE.DataAccess.SqlDatabase;
using ADE.DataContracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace ADE.DataReporterService.Controllers
{
    [ApiController, Route("[controller]")]
    public class ReportsController : ControllerBase
    {
        private readonly AdeDataContext _adeDataContext;

        private readonly ILogger<ReportsController> _logger;

        public ReportsController(AdeDataContext adeDataContext, ILogger<ReportsController> logger)
        {
            _adeDataContext = adeDataContext;
            _logger = logger;
        }

        [HttpGet]
        public async Task<IEnumerable<UserDataPoint>> GetAllAsync()
        {
            // Get Data from Azure SQL
            // TODO: we should filter, not grab all entries
            var sqlDatabaseDataPoints = await _adeDataContext.UserDataPoints.ToListAsync();

            return sqlDatabaseDataPoints;
        }
    }
}
using System;
using System.Threading.Tasks;
using ADE.DataAccess.SqlDatabase;
using ADE.DataContracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace ADE.DataIngestorService.Controllers
{
    [ApiController, Route("[controller]")]
    public class DataIngestionController : ControllerBase
    {
        private readonly AdeDataContext _adeDataContext;

        private readonly ILogger<DataIngestionController> _logger;

        public DataIngestionController(AdeDataContext adeDataContext, ILogger<DataIngestionController> logger)
        {
            _adeDataContext = adeDataContext;
            _logger = logger;
        }

        [HttpPost]
        public async Task<int> PostAsync([FromBody] UserDataPoint data)
        {
            // TODO: Sanitize, append user info
            data.UserId = Guid.NewGuid();
            data.Id = Guid.NewGuid();
            data.DataSource = "Azure SQL Database";

            await _adeDataContext.UserDataPoints.AddAsync(data);
            return await _adeDataContext.SaveChangesAsync();
        }
    }
}
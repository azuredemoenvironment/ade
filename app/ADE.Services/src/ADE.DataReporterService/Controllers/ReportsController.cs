using System.Collections.Generic;
using System.Threading.Tasks;
using ADE.DataContracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace ADE.DataReporterApi.Controllers
{
    [ApiController, Route("[controller]")]
    public class ReportsController : ControllerBase
    {
        private readonly ILogger<ReportsController> _logger;

        public ReportsController(ILogger<ReportsController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public Task<IEnumerable<UserDataPoint>> GetAsync() => Task.FromResult((IEnumerable<UserDataPoint>) new List<UserDataPoint>());
    }
}
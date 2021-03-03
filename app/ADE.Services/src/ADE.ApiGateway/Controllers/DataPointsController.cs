using System.Collections.Generic;
using System.Threading.Tasks;
using ADE.DataContracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace ADE.ApiGateway.Controllers
{
    [Authorize, ApiController, Route("[controller]")]
    public class DataPointsController : ControllerBase
    {
        private readonly ILogger<DataPointsController> _logger;

        public DataPointsController(ILogger<DataPointsController> logger)
        {
            _logger = logger;
        }

        [HttpPost]
        public Task<IEnumerable<UserDataPoint>> GetAsync() => Task.FromResult((IEnumerable<UserDataPoint>) new List<UserDataPoint>());
    }
}
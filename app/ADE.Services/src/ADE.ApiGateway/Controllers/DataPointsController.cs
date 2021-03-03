using System.Collections.Generic;
using System.Threading.Tasks;
using ADE.DataContracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using RestSharp;
using RestSharp.Authenticators;

namespace ADE.ApiGateway.Controllers
{
    [ApiController, Route("[controller]")]
    public class DataPointsController : ControllerBase
    {
        private readonly ILogger<DataPointsController> _logger;

        public DataPointsController(ILogger<DataPointsController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public async Task<IEnumerable<UserDataPoint>> GetAllAsync()
        {
            var client = new RestClient("http://localhost:5003");

            var request = new RestRequest("reports", DataFormat.Json);

            var userDataPoints = await client.GetAsync<IEnumerable<UserDataPoint>>(request);

            return userDataPoints;
        }
    }
}
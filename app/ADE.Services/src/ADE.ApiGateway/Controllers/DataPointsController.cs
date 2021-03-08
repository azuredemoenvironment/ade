using System.Collections.Generic;
using System.Threading.Tasks;
using ADE.DataContracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using RestSharp;

namespace ADE.ApiGateway.Controllers
{
    [ApiController, Route("[controller]")]
    public class DataPointsController : ControllerBase
    {
        private readonly ConnectionConfiguration _connectionConfiguration;

        private readonly ILogger<DataPointsController> _logger;

        public DataPointsController(ConnectionConfiguration connectionConfiguration, ILogger<DataPointsController> logger)
        {
            _connectionConfiguration = connectionConfiguration;
            _logger = logger;
        }

        [HttpGet]
        public async Task<IEnumerable<UserDataPoint>> GetAllAsync()
        {
            var client = new RestClient(_connectionConfiguration.DataReporterServiceUri);

            var request = new RestRequest("reports", DataFormat.Json);

            var userDataPoints = await client.GetAsync<IEnumerable<UserDataPoint>>(request);

            return userDataPoints;
        }

        [HttpPost]
        public async Task<UserDataPoint> PostAsync([FromBody] UserDataPoint data)
        {
            var client = new RestClient(_connectionConfiguration.DataIngestorServiceUri);

            var request = new RestRequest("dataingestion", DataFormat.Json);
            request.AddJsonBody(data);

            return await client.PostAsync<UserDataPoint>(request);
        }
    }
}
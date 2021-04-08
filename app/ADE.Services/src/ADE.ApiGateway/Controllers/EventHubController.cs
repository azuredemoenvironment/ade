using ADE.DataContracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using RestSharp;
using System.Threading.Tasks;

namespace ADE.ApiGateway.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class EventHubController : ControllerBase
    {
        private readonly ConnectionConfiguration _connectionConfiguration;

        private readonly ILogger<EventHubController> _logger;

        public EventHubController(ConnectionConfiguration connectionConfiguration, ILogger<EventHubController> logger)
        {
            _connectionConfiguration = connectionConfiguration;
            _logger = logger;
        }

        [HttpPost]
        public async Task<FacilityEvent> PostAsync([FromBody] FacilityEvent data)
        {
            var client = new RestClient(_connectionConfiguration.DataIngestorServiceUri);

            var request = new RestRequest("eventingestor", DataFormat.Json);
            request.AddJsonBody(data);

            return await client.PostAsync<FacilityEvent>(request);
        }
    }
}

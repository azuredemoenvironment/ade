using System.Threading.Tasks;
using ADE.DataContracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using RestSharp;

namespace ADE.ApiGateway.Controllers
{
    [Route("api/[controller]"), ApiController]
    public class EventHubController : ControllerBase
    {
        private readonly AdeConfiguration _adeConfiguration;

        private readonly ILogger<EventHubController> _logger;

        public EventHubController(AdeConfiguration adeConfiguration, ILogger<EventHubController> logger)
        {
            _adeConfiguration = adeConfiguration;
            _logger = logger;
        }

        [HttpPost]
        public async Task<FacilityEvent> PostAsync([FromBody] FacilityEvent data)
        {
            var client = new RestClient(_adeConfiguration.EventIngestorServiceUri);

            var request = new RestRequest("eventingestor", DataFormat.Json);
            request.AddJsonBody(data);

            return await client.PostAsync<FacilityEvent>(request);
        }
    }
}
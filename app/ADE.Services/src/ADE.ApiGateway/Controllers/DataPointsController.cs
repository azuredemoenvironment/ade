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
        private readonly AdeConfiguration _adeConfiguration;

        private readonly ILogger<DataPointsController> _logger;

        public DataPointsController(AdeConfiguration adeConfiguration, ILogger<DataPointsController> logger)
        {
            _adeConfiguration = adeConfiguration;
            _logger = logger;
        }

        [HttpGet]
        public async Task<IEnumerable<UserDataPoint>> GetAllAsync()
        {
            var client = new RestClient(_adeConfiguration.DataReporterServiceUri);

            var request = new RestRequest("reports", DataFormat.Json);

            var userDataPoints = await client.GetAsync<IEnumerable<UserDataPoint>>(request);

            return userDataPoints;
        }

        [HttpPost]
        public async Task<UserDataPoint> PostAsync([FromBody] UserDataPoint data)
        {
            var client = new RestClient(_adeConfiguration.DataIngestorServiceUri);

            var request = new RestRequest("dataingestion", DataFormat.Json);
            request.AddJsonBody(data);

            var returnedData = await client.PostAsync<UserDataPoint>(request);

            var eventRestClient = new RestClient(_adeConfiguration.EventIngestorServiceUri);

            var eventRequest = new RestRequest("eventingestor", DataFormat.Json);

            var facilityEvent = new FacilityEvent
            {
                EventDate = returnedData.CreatedAt,
                FacilityId = returnedData.StringValue,
                TenantId = returnedData.DataSource,
                InUse = true,
                UnitId = returnedData.UserId.ToString()
            };

            eventRequest.AddJsonBody(facilityEvent);

            await eventRestClient.PostAsync<FacilityEvent>(eventRequest);

            return returnedData;
        }
    }
}
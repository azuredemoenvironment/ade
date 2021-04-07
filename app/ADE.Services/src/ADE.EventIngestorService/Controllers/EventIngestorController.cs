using System;
using System.Threading.Tasks;
using Microsoft.ApplicationInsights;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using ADE.DataContracts;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;
using System.Text;

namespace ADE.EventIngestorService.Controllers
{
    [ApiController, Route("[controller]")]
    public class EventIngestorController : ControllerBase
    {

        private readonly ILogger<EventIngestorController> _logger;
        private readonly ConnectionConfiguration _connectionConfiguration;
        private readonly TelemetryClient _telemetry;


        public EventIngestorController(TelemetryClient telemetry, ILogger<EventIngestorController> logger, ConnectionConfiguration connectionConfiguration)
        {
            _telemetry = telemetry;
            _logger = logger;
            _connectionConfiguration = connectionConfiguration;
        }


        [HttpPost]
        public async Task<FacilityEvent> PostAsync([FromBody] FacilityEvent facilityEvent)
        {
            // TODO: Sanitize, append user info
            facilityEvent.Id = Guid.NewGuid();
            facilityEvent.CreatedAt = DateTime.UtcNow;
            //TODO: create some common things for the contracts to keep things DRY
            //_telemetry.TrackEvent("Event Ingest", facilityEvent.ToDictionary());

            //add code to send to event hub

            // Create a producer client that you can use to send events to an event hub
            await using (var producerClient = new EventHubProducerClient(_connectionConfiguration.EventHubConnectionString, _connectionConfiguration.EventHubNameSpace))
            {
                // Create a batch of events 
                using EventDataBatch eventBatch = await producerClient.CreateBatchAsync();

                // Add events to the batch. An event is a represented by a collection of bytes and metadata. 
                eventBatch.TryAdd(new EventData(Encoding.UTF8.GetBytes("Sink One")));
                eventBatch.TryAdd(new EventData(Encoding.UTF8.GetBytes("Sink Two")));
                eventBatch.TryAdd(new EventData(Encoding.UTF8.GetBytes("Sink Three")));

                // Use the producer client to send the batch of events to the event hub
                await producerClient.SendAsync(eventBatch);
                Console.WriteLine("A batch of 3 events has been published.");

                return facilityEvent;
            }
        }
    }
}
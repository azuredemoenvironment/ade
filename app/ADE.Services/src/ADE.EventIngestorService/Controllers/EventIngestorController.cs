using System;
using System.Threading.Tasks;
using Microsoft.ApplicationInsights;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using ADE.DataContracts;

namespace ADE.EventIngestorService.Controllers
{
    [ApiController, Route("[controller]")]
    public class EventIngestorController : ControllerBase
    {
     
        private readonly ILogger<EventIngestorController> _logger;

        private readonly TelemetryClient _telemetry;

        public EventIngestorController(TelemetryClient telemetry, ILogger<EventIngestorController> logger)
        {
            _telemetry = telemetry;
            _logger = logger;
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
          

            return facilityEvent;
        }
    }
}
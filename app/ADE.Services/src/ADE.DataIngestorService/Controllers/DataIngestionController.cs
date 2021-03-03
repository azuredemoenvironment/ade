using System.Threading.Tasks;
using ADE.DataContracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace ADE.DataIngestorApi.Controllers
{
    [ApiController, Route("[controller]")]
    public class DataIngestionController : ControllerBase
    {
        private readonly ILogger<DataIngestionController> _logger;

        public DataIngestionController(ILogger<DataIngestionController> logger)
        {
            _logger = logger;
        }

        [HttpPost]
        public Task PostAsync(UserDataPoint data) => Task.CompletedTask;
    }
}
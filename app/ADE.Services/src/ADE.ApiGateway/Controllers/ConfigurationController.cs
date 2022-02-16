using ADE.DataContracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace ADE.ApiGateway.Controllers
{
    [ApiController, Route("[controller]")]
    public class ConfigurationController
    {
        private readonly AdeConfiguration _adeConfiguration;

        private readonly ILogger<ConfigurationController> _logger;

        public ConfigurationController(AdeConfiguration adeConfiguration, ILogger<ConfigurationController> logger)
        {
            _adeConfiguration = adeConfiguration;
            _logger = logger;
        }

        [HttpGet]
        public AdeConfiguration GetAsync()
        {
            _logger.LogInformation("Request to return ADE Configuration");
            return _adeConfiguration;
        }
    }
}
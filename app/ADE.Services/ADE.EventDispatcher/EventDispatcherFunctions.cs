using System;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace ADE.EventDispatcher
{
    public static class EventDispatcherFunctions
    {
        [Function("datapointingestorevent")]
        public static void Run([EventHubTrigger("evh_ade_datapointingestor", Connection = "eventhubconnectionstring")] string[] input, FunctionContext context)
        {
            var logger = context.GetLogger("datapointingestorevent");
            logger.LogInformation($"First Event Hubs triggered message: {input[0]}");
        }
    }
}

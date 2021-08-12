using System;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace ADE.EventDispatcher
{
    public static class Function1
    {
        [Function("Function1")]
        public static void Run([EventHubTrigger("evh_brmar_ade", Connection = "eventhubconnectionstring")] string[] input, FunctionContext context)
        {
            var logger = context.GetLogger("Function1");
            logger.LogInformation($"First Event Hubs triggered message: {input[0]}");
        }
    }
}

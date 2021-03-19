using System.Collections.Generic;

namespace ADE.DataContracts
{
    public static class UserDataPointExtensions
    {
        public static IDictionary<string, string> ToDictionary(this UserDataPoint udp) =>
            new Dictionary<string, string>
            {
                {
                    "BooleanValue", udp.BooleanValue.ToString()
                },
                {
                    "CreatedAt", udp.CreatedAt.ToString()
                },
                {
                    "DataSource", udp.DataSource
                },
                {
                    "DecimalValue", udp.DecimalValue.ToString()
                },
                {
                    "Id", udp.Id.ToString()
                },
                {
                    "IntegerValue", udp.IntegerValue.ToString()
                },
                {
                    "StringValue", udp.StringValue
                },
                {
                    "UserId", udp.UserId.ToString()
                }
            };
    }
}
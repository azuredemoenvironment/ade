using System;

namespace ADE.DataContracts
{
    public class UserDataPoint
    {
        public bool BooleanValue { get; set; }

        public DateTime CreatedAt { get; set; }

        public string DataSource { get; set; }

        public double DecimalValue { get; set; }

        public Guid Id { get; set; }

        public int IntegerValue { get; set; }

        public string StringValue { get; set; }

        public Guid UserId { get; set; }
    }
}
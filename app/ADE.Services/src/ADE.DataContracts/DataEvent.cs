using System;

namespace ADE.DataContracts
{
    public class DataEvent
    {
        public DateTime CreatedAt { get; set; }

        public DateTime EventDate { get; set; }

        public Guid Id { get; set; }

        public bool InUse { get; set; }

        public string TenantId { get; set; }

        public string Topic { get; set; }

        public string UserId { get; set; }
    }
}
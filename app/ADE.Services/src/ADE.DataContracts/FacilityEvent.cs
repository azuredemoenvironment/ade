using System;

namespace ADE.DataContracts
{
    public class FacilityEvent
    {
        public DateTime CreatedAt { get; set; }

        public Guid Id { get; set; }

        public string TenantId { get; set; }

        public string FacilityId {get; set;}

        public string UnitId {get; set;}

        public bool InUse {get; set;}

        public DateTime EventDate {get; set;}
    }
}
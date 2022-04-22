using System;

namespace ADE.DataContracts
{
    public class UserLocalizedDataPoint
    {
        public string Content { get; set; }

        public DateTime CreatedAt { get; set; }

        public string DataSource { get; set; }

        public Guid Id { get; set; }

        public string Location { get; set; }

        public Guid UserId { get; set; }
    }
}
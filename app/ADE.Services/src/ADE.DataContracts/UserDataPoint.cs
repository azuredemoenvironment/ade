using System;

namespace ADE.DataContracts
{
    public class UserDataPoint
    {
        public string Content { get; set; }

        public DateTime CreatedAt { get; set; }

        public string DataSource { get; set; }

        public Guid Id { get; set; }

        public Guid UserId { get; set; }
    }
}
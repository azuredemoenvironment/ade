using System;

namespace ADE.DataContracts
{
    public class User
    {
        public DateTime CreatedAt { get; set; }

        public Guid Id { get; set; }

        public string Name { get; set; }
    }
}
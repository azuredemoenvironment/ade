using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ADE.DataContracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace ADE.DataReporterService.Controllers
{
    [ApiController, Route("[controller]")]
    public class ReportsController : ControllerBase
    {
        private readonly ILogger<ReportsController> _logger;

        public ReportsController(ILogger<ReportsController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public Task<IEnumerable<UserDataPoint>> GetAsync() => Task.FromResult((IEnumerable<UserDataPoint>) new List<UserDataPoint>()
        {
            new UserDataPoint
            {
                Content = "Sample 001",
                CreatedAt = DateTime.UtcNow,
                DataSource = "MockData",
                UserId = Guid.NewGuid()
            },
            new UserDataPoint
            {
                Content = "Sample 002",
                CreatedAt = DateTime.UtcNow,
                DataSource = "MockData",
                UserId = Guid.NewGuid()
            },
            new UserDataPoint
            {
                Content = "Sample 003",
                CreatedAt = DateTime.UtcNow,
                DataSource = "MockData",
                UserId = Guid.NewGuid()
            }
        });
    }
}
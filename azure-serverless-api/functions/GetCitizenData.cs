using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;

namespace CitizenPortalApi.Functions
{
    public static class GetCitizen
    {
        [FunctionName("GetCitizen")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = "citizens/{id?}")] HttpRequest req,
            string id,
            ILogger log)
        {
            log.LogInformation("Processing request for citizen ID: {id}", id);

            var citizens = new Dictionary<string, object>
            {
                { "1001", new { name = "Aarav Kumar", city = "Hyderabad", service = "Aadhar Renewal" } },
                { "1002", new { name = "Divya Sharma", city = "Bangalore", service = "Birth Certificate" } }
            };

            if (string.IsNullOrEmpty(id))
                return new BadRequestObjectResult("Please provide a citizen ID in the URL, e.g. /api/citizens/1001");

            return citizens.ContainsKey(id)
                ? new OkObjectResult(citizens[id])
                : new NotFoundObjectResult(new { message = "Citizen not found" });
        }
    }
}

using ADE.ServiceBase;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.OpenApi.Models;

namespace ADE.ApiGateway
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            app.UseSwagger();
            app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "ADE.ApiGateway v1"));

            // app.UseHttpsRedirection();

            app.UseRouting();

            app.UseCors();

            // app.UseAuthentication();
            // app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
                endpoints.MapGet("/debug-config", ctx =>
                {
                    var config = (Configuration as IConfigurationRoot).GetDebugView();
                    return ctx.Response.WriteAsync(config);
                });
            });
        }

        public void ConfigureServices(IServiceCollection services)
        {
            services.AddAdeConfiguration(Configuration);

            services.AddApplicationInsightsTelemetry(Configuration);

            services.AddCors(options =>
            {
                options.AddDefaultPolicy(
                    builder =>
                    {
                        builder.AllowAnyOrigin();
                        builder.AllowAnyHeader();
                        builder.AllowAnyMethod();
                    });
            });

            // services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            //     .AddMicrosoftIdentityWebApi(Configuration.GetSection("AzureAdB2C"));

            services.AddControllers();
            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo
                {
                    Title = "ADE.ApiGateway",
                    Version = "v1"
                });
            });
        }
    }
}
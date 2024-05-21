using System.Configuration;
using Azure.Core.Diagnostics;
using Azure.Data.AppConfiguration;
using Azure.Identity;
using Microsoft.AspNetCore.Mvc;
using TodoApi.Models;
using web_api_demo_container.Services;

namespace web_api_demo_container.Controllers;

[ApiController]
[Route("[controller]")]
public class ConfigController : ControllerBase
{
    private readonly ILogger<WeatherForecastController> _logger;
    private readonly IConfiguration _configuration;
    private readonly IWebHostEnvironment _env;

    public ConfigController(ILogger<WeatherForecastController> logger, IConfiguration configuration, IWebHostEnvironment env)
    {
        _logger = logger;
        _configuration = configuration;
        _env = env;
    }

    /// <summary>
    /// Get the environment short name based on how the ASPNETCORE_ENVIRONMENT variable is set
    /// </summary>
    /// <returns></returns> <summary>
    /// 
    /// </summary>
    /// <returns></returns>
    [HttpGet("getenvironment")]
    public string GetEnvironment()
    {
        if (_env.IsDevelopment())
        {
            return "dev";
        }
        else if (_env.IsStaging())
        {
            return "test";
        }
        else if (_env.IsProduction())
        {
            return "prod";
        }
        else
        {
            return "Unknown";
        }
    }

    /// <summary>
    /// Example of getting a configuration setting from Azure App Configuration using a connection string, but don't use this as it requires
    /// you to save the connection string. Use the MSI version instead.
    /// </summary>
    /// <returns></returns> <summary>
    /// 
    /// </summary>
    /// <returns></returns>
    [Obsolete("Use GetWithMSIAsync instead")] 
    [HttpGet("getconfig")]
    public async Task<ConfigItemDTO> GetWithConnectingStringAsync()
    {
        //get connection string from appsettings.json
        string connectionString = _configuration.GetValue<string>("AppConfig:ConnectionString");
        var client = new ConfigurationClient(connectionString);
        ConfigurationSetting setting = await client.GetConfigurationSettingAsync("TestApp:Settings:Message",GetEnvironment());

        return new ConfigItemDTO(setting.Value);
    }

    [HttpGet("getconfigwithmsi")]
    public async Task<ConfigItemDTO> GetWithMSIAsync()
    {
        //enable logging to debug the DefaultAzureCredential
        //AzureEventSourceListener.CreateConsoleLogger();

        //get endpoint from appsettings.json
        string endpoint = _configuration.GetValue<string>("AppConfig:Endpoint");
        var client = new ConfigurationClient(new Uri(endpoint), new DefaultAzureCredential());
        ConfigurationSetting setting = await client.GetConfigurationSettingAsync("TestApp:Settings:Message",GetEnvironment());

        return new ConfigItemDTO(setting.Value);
    }
}

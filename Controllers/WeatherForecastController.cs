using Microsoft.AspNetCore.Mvc;
using web_api_demo_container.Services;

namespace web_api_demo_container.Controllers;

[ApiController]
[Route("[controller]")]
public class WeatherForecastController : ControllerBase
{
    private readonly ILogger<WeatherForecastController> _logger;
    private readonly IWeatherService _weatherService;

    public WeatherForecastController(ILogger<WeatherForecastController> logger, IWeatherService weatherService)
    {
        _logger = logger;
        _weatherService = weatherService;
    }

    [HttpGet(Name = "GetAsyncWeatherForecast")]
    public async Task<IEnumerable<WeatherForecast>> GetAsync()
    {
        return await _weatherService.GetWeather();
    }

}

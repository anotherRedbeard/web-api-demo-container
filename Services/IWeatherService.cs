namespace web_api_demo_container.Services
{
    public interface IWeatherService
    {
        Task<List<WeatherForecast>> GetWeather();
 
    }
}
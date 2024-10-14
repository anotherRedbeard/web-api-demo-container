namespace web_api_demo_container.Services
{
    public class InMemoryWeatherService : IWeatherService
    {
        private static readonly string[] Summaries = new[]
        {
            "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching", "Awesome"
        };

        public Task<List<WeatherForecast>> GetWeather()
        {
            var weather = Enumerable.Range(1, 5).Select(index => new WeatherForecast
                {
                    Date = DateTime.Now.AddDays(index),
                    TemperatureC = Random.Shared.Next(-20, 55),
                    Summary = "stage-" + Summaries[Random.Shared.Next(Summaries.Length)]
                }).ToList();

            return Task.FromResult(weather);
        }
    }
}
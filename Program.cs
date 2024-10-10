using Microsoft.EntityFrameworkCore;
using TodoApi.Models;
using Microsoft.Net.Http.Headers;
using web_api_demo_container.Services;
using Azure.Identity;
using Microsoft.Extensions.Configuration.AzureAppConfiguration;

IConfigurationRefresher refresher = null!;
var builder = WebApplication.CreateBuilder(args);

// Add Application Insights telemetry
builder.Services.AddApplicationInsightsTelemetry(options =>
{
    options.ConnectionString = builder.Configuration["ApplicationInsights:ConnectionString"];
});

// Add services to the container.

builder.Services.AddControllers();
builder.Services.AddDbContext<TodoContext>(opt =>
    opt.UseInMemoryDatabase("TodoList"));
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// get the current environment
var env = builder.Environment;

// map the environment
string label;
switch (env.EnvironmentName)
{
    case "Development":
        label = "dev";
        break;
    case "Staging":
        label = "test";
        break;
    case "Production":
        label = "prod";
        break;
    default:
        label = "dev";
        break;
}

//add azure app configuration, I may use this later, but commenting out for now
//this is how with a connectionString
//string connectionString = builder.Configuration["AppConfig:ConnectionString"];
//builder.Configuration.AddAzureAppConfiguration(connectionString);
//this is how with MSI, but I only want to execute this if AppConfig:Endpoint is set
Console.WriteLine($"AppConfig:Endpoint = {builder.Configuration["AppConfig:Endpoint"]}");
if (!string.IsNullOrEmpty(builder.Configuration["AppConfig:Endpoint"]))
{
    builder.Configuration.AddAzureAppConfiguration(options =>
    {
        options.Connect(
            new Uri(builder.Configuration["AppConfig:Endpoint"]),
            new DefaultAzureCredential())
        .Select(KeyFilter.Any, label) //filter the keys to only those with the environment label
        .ConfigureRefresh(refresh =>
        {
            refresh.Register("TestApp:Settings:Sentinel",refreshAll: true);
        }); //register a sentinel key for refresh

        refresher = options.GetRefresher(); //get the refresher so we can inject it into our services that will need it
    });

    builder.Services.AddSingleton<IConfigurationRefresher>(refresher);
}

builder.Services.AddSingleton<IWeatherService, InMemoryWeatherService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

var corsAllowedHosts = builder.Configuration["CorsAllowedHosts"].Split(',');

//policy.WithOrigins("https://localhost:7270","http://localhost:5118","https://win-wire-app--8nfao0p.redgrass-633dc5ff.eastus.azurecontainerapps.io")
app.UseCors(policy => policy
    .WithOrigins(corsAllowedHosts)
    .AllowAnyMethod()
    .WithHeaders(Microsoft.Net.Http.Headers.HeaderNames.ContentType)
);


app.UseAuthorization();

app.MapControllers();

app.Run();

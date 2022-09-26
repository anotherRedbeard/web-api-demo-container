using Microsoft.EntityFrameworkCore;
using TodoApi.Models;
using Microsoft.Net.Http.Headers;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
builder.Services.AddDbContext<TodoContext>(opt =>
    opt.UseInMemoryDatabase("TodoList"));
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

var allowedHosts = builder.Configuration.GetSection("AllowedHosts").GetChildren().Select(x => x.Value).ToArray();

//policy.WithOrigins("https://localhost:7270","http://localhost:5118","https://win-wire-app--8nfao0p.redgrass-633dc5ff.eastus.azurecontainerapps.io")
app.UseCors(policy => policy
    .WithOrigins(allowedHosts)
    .AllowAnyMethod()
    .WithHeaders(Microsoft.Net.Http.Headers.HeaderNames.ContentType)
);


app.UseAuthorization();

app.MapControllers();

app.Run();

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 5209

ENV ASPNETCORE_URLS=http://+:5209

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["web-api-demo-container.csproj", "./"]
RUN dotnet restore "web-api-demo-container.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "web-api-demo-container.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "web-api-demo-container.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "web-api-demo-container.dll"]

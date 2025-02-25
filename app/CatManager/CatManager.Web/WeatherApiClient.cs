using Dapr.Client;

namespace CatManager.Web;


public class WeatherApiClientDapr(DaprClient client)
{
    public async Task<WeatherForecast[]> GetWeatherAsync(
        int maxItems = 10, CancellationToken cancellationToken = default)
    {
        var forecasts =
            await client.InvokeMethodAsync<List<WeatherForecast>>(
                HttpMethod.Get,
                "apiservice",
                "weatherforecast",
                cancellationToken);

        return forecasts?.Take(maxItems)?.ToArray() ?? [];
    }
}

public class WeatherApiClient(HttpClient httpClient)
{
    public async Task<WeatherForecast[]> GetWeatherAsync(int maxItems = 10, CancellationToken cancellationToken = default)
    {
        List<WeatherForecast>? forecasts = null;

        await foreach (var forecast in httpClient.GetFromJsonAsAsyncEnumerable<WeatherForecast>("/weatherforecast", cancellationToken))
        {
            if (forecasts?.Count >= maxItems)
            {
                break;
            }
            if (forecast is not null)
            {
                forecasts ??= [];
                forecasts.Add(forecast);
            }
        }

        return forecasts?.ToArray() ?? [];
    }
}

public record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}

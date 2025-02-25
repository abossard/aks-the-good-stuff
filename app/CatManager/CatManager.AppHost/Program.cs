using Aspire.Hosting.Dapr;
var builder = DistributedApplication.CreateBuilder(args);

var cache = builder.AddRedis("cache");

var apiService = builder.AddProject<Projects.CatManager_ApiService>("apiservice").WithDaprSidecar();

builder.AddProject<Projects.CatManager_Web>("webfrontend")
    .WithDaprSidecar()
    .WithExternalHttpEndpoints()
    .WithReference(cache)
    .WaitFor(cache)
    .WithReference(apiService)
    .WaitFor(apiService);

builder.Build().Run();

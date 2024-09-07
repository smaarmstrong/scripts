#!/bin/zsh

# Navigate to the app directory
cd ~/{project}/{.net app}

# Remove the boilerplate controllers and other files
rm -f Controllers/WeatherForecastController.cs
rm -f WeatherForecast.cs
rm -f Startup.cs # Remove the Startup.cs file if it exists

# Retain necessary code in Program.cs for Swagger, HTTPS redirection, etc.
cat <<EOL > Program.cs
var builder = WebApplication.CreateBuilder(args);
// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddControllers();
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
app.UseAuthorization();
app.MapControllers();
app.Run();
EOL

# Print a message indicating the cleanup is done
echo "Boilerplate code removed and minimal setup created."

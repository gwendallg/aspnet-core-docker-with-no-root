FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
# Set listen aspnet.core port ( more 1024 if you use a no root )
# cf: https://stackoverflow.com/questions/37365277/how-to-specify-the-port-an-asp-net-core-application-is-hosted-on
# cf: https://stackoverflow.com/questions/53544469/how-to-run-net-core-2-application-in-docker-on-linux-as-non-root/53544813
ENV ASPNETCORE_URLS http://+:5001
WORKDIR /app
COPY --from=build-env /app/out .
# Create group / user used for dotnet
RUN groupadd dotnet_users && \
    useradd -ms /bin/bash dotnet_user && \
    chmod 770 /app && \
    chown -R dotnet_user:dotnet_users /app
# force docker to use dotnet user

# !!!!!! remove to production installed to proof of concept ( ps )
RUN apt-get update && apt-get install -y procps
# !!!!!!

USER dotnet_user

# export asp.net core api port
EXPOSE 5001
ENTRYPOINT ["dotnet", "run-no-root.dll"]

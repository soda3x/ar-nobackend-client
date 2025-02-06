# Arma Reforger No Backend Packager

Create a package to distribute to players so that they can play on your Arma Reforger servers with no backend

This script will, given a valid Arma Reforger dedicated server configuration file and directory containing addons, package up all required addons and generate a launch script for your clients to use to connect directly to your server and put the into a zip file for easy sharing. No fuss or hassle.



## Requirements

* Your configuration file **must** contain a value for public address and port.
* You must have [this mod](https://reforger.armaplatform.com/workshop/6324F7124A9768FB-NoBackendScenarioLoader) in your addons directory and in your server configuration as a mod

## Usage

```txt
Usage: ar-nb-package.ps1 -ConfigFile <path> -AddonsDir <path> -OutputDir <path>
Parameters:
  -ConfigFile  Path to the JSON configuration file.
  -AddonsDir   Path to the addons directory.
  -OutputDir   Path to where the packaged client files should be created.
  -Help        Show this help message.
```

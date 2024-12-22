# App 

The frontend client is built with Godot because it is the most familiar way for building a UI.
  - Tradeoff: I’m guessing I’m missing out on standard mobile functionality (e.g. notifications); not learning standard FE application development tools (e.g. React)

## Deployment
Just manually building the application onto my Android phone while plugged in. Haven't bothered even with a web version (yet). 

A local `app/export.cfg` file for the format:
```
[secrets]
api_url="<API_URL>"
```
is necessary for making backend requests.
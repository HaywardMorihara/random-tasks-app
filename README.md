# Random Tasks App

An application where you can:

1. With as few taps as possible, add a new task to my “random stream of distraction tasks" 
2. When I have ~5 minutes, ask for a task from this stream, randomly
3. Mark a Task as completed & filter it out of random results

This is for tasks that are "distractions" -- that don't have to get done and maybe I shouldn't take the time to do. Putting them in a "random stream" helps me trick myself into letting go of them.


## Architecture

### Frotend: Godot 
The frontend is built with Godot because it is the most familiar way for building a UI
  - Tradeoff: I’m guessing I’m missing out on standard mobile functionality (e.g. notifications); not learning standard FE application development tools (e.g. React)

**Deployment:** Just manually building the application onto my Android phone while plugged in. Haven't bothered even with a web version (yet). 

### Backend: AWS
The backend is built with AWS. See [backend/README](backend/README.md) for more info about the architecture and how to deploy/test it.


## Future 
Future plans are documented & tracked in [my private Notion page](https://www.notion.so/nathaniel-morihara/Random-Task-App-13ef0f8ea17980269fefe296ceb167be). 
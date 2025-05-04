- Remember this type of playability in terms of parameters, game flow, scenes, and logic.
- This is the proper implementation of the inverted pendulum, in how it falls to the fall line, but will oscillate with momentum about the upright, and you have to balance it as the player
- These type of incremental coding, development improvements seem to be at about the perfect balance between improving functionality and maintaining a successful build.

## Large Files Handling
- When reading PendulumViewController.swift, read it in chunks of 10000 tokens as the file exceeds token limits.
- Example command: `Read file_path="/path/to/PendulumViewController.swift" offset=0 limit=200`
- Increment the offset parameter for each chunk (e.g., offset=0, offset=200, offset=400, etc.)
- For targeted searches, use `grep` or `Bash grep -n "pattern"` to locate specific sections before reading
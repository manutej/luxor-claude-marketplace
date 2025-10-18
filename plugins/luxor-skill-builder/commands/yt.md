---
description: Summarize YouTube video(s) using the yt CLI tool with various format and processing options
args:
  - name: url
    description: YouTube URL or video ID (required)
  - name: flags
    description: Optional flags (-d detailed, -a academic, -b bullets, -t thinking, --batch, -o output)
---

# YouTube Video Summarizer

You are tasked with summarizing YouTube video(s) using the local `yt` CLI tool.

## Arguments Provided
- URL/Video ID: {{url}}
- Additional flags: {{flags}}

## Your Task

1. **Parse the arguments:**
   - Extract the YouTube URL(s) or video ID(s)
   - Identify any format flags: `-c` (concise), `-d` (detailed), `-a` (academic), `-b` (bullets)
   - Check for processing flags: `-t` (extended thinking), `--chunking`, `--chunk-size`
   - Check for output flags: `-o` (output file), `-v` (verbose)
   - Check for batch mode: `--batch`

2. **Execute the yt command:**
   - Run the `./bin/yt` command with the provided URL(s) and flags
   - Use proper flag combinations based on user intent
   - Handle multiple URLs if `--batch` is specified

3. **Handle the output:**
   - Display the summary result to the user
   - If an output file is specified with `-o`, confirm the file was created and show its location
   - If verbose mode is enabled, show processing details
   - If errors occur, explain them and suggest fixes

## Command Structure

The basic command structure is:
```bash
./bin/yt <url> [flags]
```

## Common Patterns

### Single Video
```bash
# Quick summary
./bin/yt https://youtube.com/watch?v=VIDEO_ID

# Detailed summary
./bin/yt https://youtube.com/watch?v=VIDEO_ID -d

# Academic notes
./bin/yt https://youtube.com/watch?v=VIDEO_ID -a

# With deep thinking
./bin/yt https://youtube.com/watch?v=VIDEO_ID -a -t
```

### Multiple Videos
```bash
# Batch process
./bin/yt url1 url2 url3 --batch

# Or process them individually
```

### With Custom Output
```bash
./bin/yt <url> -d -o summaries/custom-name.md
```

## Important Notes

- The yt tool requires `ANTHROPIC_API_KEY` to be set in the environment or `.env` file
- Default output directory is `summaries/`
- Summaries are automatically saved with generated filenames unless `-o` is specified
- The tool supports both full YouTube URLs and video IDs
- Use `-t` flag for deeper analysis on complex/technical content
- For batch processing, provide multiple URLs space-separated with `--batch` flag

## Error Handling

If the command fails:
1. Check if the `ANTHROPIC_API_KEY` is configured
2. Verify the YouTube URL is valid and the video has captions available
3. Check if the `./bin/yt` script is executable (`chmod +x ./bin/yt`)
4. Ensure all required Python dependencies are installed

## Your Response

After running the command:
1. Show a brief summary of what was processed
2. Display the output location if a file was created
3. If the summary is short enough, show it inline
4. Provide any relevant insights or next steps

Now execute the command with the provided arguments.

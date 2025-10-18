# /summarize

Extract and summarize YouTube video content into structured, digestible summaries with key points, timestamps, and actionable insights. Transform hours of video into minutes of reading while preserving essential knowledge.

## Usage

```bash
/summarize <youtube-url>
/summarize <youtube-url> --format <type>
/summarize <youtube-url> --output <filename>
/summarize <video-id> [options]
```

## Parameters

### Required
- `youtube-url` or `video-id` (string): YouTube video URL or video ID
  - Accepts: Full URL, short URL (youtu.be), video ID only
  - Examples: `https://youtube.com/watch?v=dQw4w9WgXcQ`, `youtu.be/dQw4w9WgXcQ`, `dQw4w9WgXcQ`

### Optional Flags
- `--format <type>`: Summary format style
  - `detailed` (default): Comprehensive summary with chapters and timestamps
  - `concise`: Executive summary + key points (quick reference)
  - `bullets`: Bullet-point list of takeaways
  - `chapters`: Chapter-based breakdown
  - `academic`: Structured notes format for learning

- `--output <filename>`: Custom output filename
  - Default: `docs/<video-title>-summary.md`
  - Can specify full path: `summaries/tutorial-01.md`

- `--language <code>`: Transcript language preference
  - Default: Auto-detect or English
  - Examples: `en`, `es`, `fr`, `de`, `ja`

- `--timestamps`: Include clickable timestamp links (when supported)

- `--no-transcript`: Generate summary from metadata only (when transcript unavailable)

## Examples

### Example 1: Basic Video Summary
```bash
/summarize "https://youtube.com/watch?v=dQw4w9WgXcQ"
```

**What it does**:
1. Extracts video ID from URL
2. Fetches video metadata (title, channel, duration, description)
3. Retrieves transcript (auto-generated or manual)
4. Analyzes content structure and key points
5. Generates detailed summary with chapters
6. Saves to `docs/VIDEO-TITLE-SUMMARY.md`

**Output Example**:
```markdown
# Video Summary: Advanced React Patterns

## Metadata
- Video ID: dQw4w9WgXcQ
- Duration: 45:32
- Channel: TechTalks
- Published: 2024-10-01

## Executive Summary
This talk covers advanced React patterns including render props,
higher-order components, and hooks composition. Ideal for intermediate
to advanced React developers looking to improve code reusability.

## Key Points
- 00:02:15 - Introduction to render props pattern
- 00:08:45 - Implementing HOCs for cross-cutting concerns
- 00:15:30 - Custom hooks composition strategies
...
```

### Example 2: Concise Summary for Quick Scanning
```bash
/summarize "https://youtube.com/watch?v=abc123" --format concise
```

**What it does**:
1. Extracts transcript and metadata
2. Identifies 5-10 most important points
3. Generates brief executive summary
4. Creates quick-reference format
5. Saves to docs/ folder

**Output Example**:
```markdown
# Kubernetes Deployment Best Practices - Quick Summary

**Duration**: 32:18 | **Channel**: DevOps Weekly

## TL;DR
Comprehensive guide to production-ready Kubernetes deployments
covering health checks, resource limits, and rolling updates.

## Key Takeaways
1. Always define resource limits and requests
2. Use liveness and readiness probes correctly
3. Implement proper rolling update strategies
4. Configure horizontal pod autoscaling
5. Use secrets management tools (not ConfigMaps for secrets)

## Worth Watching?
Essential viewing for DevOps engineers deploying to Kubernetes.
Assumes basic k8s knowledge. Highly practical with code examples.
```

### Example 3: Technical Tutorial with Academic Format
```bash
/summarize "https://youtube.com/watch?v=tutorial123" --format academic
```

**What it does**:
1. Structures content as course notes
2. Extracts concepts with definitions
3. Captures examples and demonstrations
4. Organizes learning objectives
5. Includes practice exercises mentioned

**Output Example**:
```markdown
# Course Notes: Introduction to Machine Learning

**Lecture**: 3 of 10
**Topic**: Linear Regression

## Learning Objectives
- Understand linear regression fundamentals
- Implement gradient descent algorithm
- Evaluate model performance

## Main Concepts

### Concept 1: Linear Regression
- **Definition**: Statistical method for modeling relationship
  between dependent and independent variables
- **Timestamp**: 00:03:45
- **Explanation**: Uses linear equation y = mx + b to predict values
- **Example**: Predicting house prices based on square footage

### Concept 2: Gradient Descent
...
```

### Example 4: Conference Talk Summary
```bash
/summarize "https://youtube.com/watch?v=conf2024" --format detailed --output docs/conferences/react-conf-2024.md
```

**What it does**:
1. Extracts full conference talk transcript
2. Identifies speaker and context
3. Breaks down by major sections/topics
4. Captures technical details and code references
5. Lists resources and tools mentioned
6. Saves to custom location

**Output**: `docs/conferences/react-conf-2024.md`

### Example 5: Short Video with Bullet Points
```bash
/summarize "youtu.be/short123" --format bullets
```

**What it does**:
1. Generates rapid-fire list format
2. One point per key insight
3. Minimal context, maximum density
4. Perfect for short tutorials or tips

**Output Example**:
```markdown
# Quick Tips: Git Workflow Optimization

**Duration**: 8:42

## Key Points
- Use `git commit --fixup` for cleaner history
- Set up global `.gitignore` for OS-specific files
- Leverage `git bisect` for bug hunting
- Configure `git aliases` for common operations
- Use `git stash` with names for better organization
- Enable `git rerere` to cache merge conflict resolutions
```

### Example 6: Interview or Podcast Summary
```bash
/summarize "https://youtube.com/watch?v=interview" --format chapters
```

**What it does**:
1. Detects natural conversation breaks
2. Organizes by topic rather than time
3. Extracts key insights from each speaker
4. Captures notable quotes
5. Lists resources mentioned

**Output Example**:
```markdown
# Interview Summary: Building Scalable Systems with Jane Doe

## Metadata
- Duration: 1:32:45
- Interviewer: Tech Podcast Host
- Guest: Jane Doe, Principal Engineer at TechCorp

## Executive Summary
Deep dive into scalable system design covering microservices,
database sharding, and caching strategies from a veteran engineer.

## Topics Discussed

### Career Journey (00:00:00 - 00:15:30)
- Started as frontend developer
- Transitioned to backend and distributed systems
- Lessons learned from scaling to 100M users

### Microservices Architecture (00:15:30 - 00:42:15)
- When to use microservices vs monolith
- Service discovery patterns
- Inter-service communication strategies
> "Don't start with microservices. Earn them through pain." - 00:28:45

### Database Scaling (00:42:15 - 01:05:00)
- Horizontal vs vertical scaling
- Sharding strategies
- Consistency vs availability tradeoffs
...
```

### Example 7: Playlist/Series Processing
```bash
/summarize "https://youtube.com/playlist?list=PLxxx" --format detailed
```

**What it does**:
1. Detects playlist URL
2. Prompts for batch processing confirmation
3. Processes each video in sequence
4. Generates individual summaries
5. Creates master index document
6. Saves to organized directory structure

**Output**:
```
summaries/react-fundamentals/
  ├── INDEX.md (course overview)
  ├── 01-intro-to-react-summary.md
  ├── 02-jsx-and-components-summary.md
  ├── 03-state-and-props-summary.md
  └── ...
```

### Example 8: Non-English Video
```bash
/summarize "https://youtube.com/watch?v=spanish" --language es
```

**What it does**:
1. Requests Spanish transcript
2. Processes in original language
3. Optionally translates key points
4. Notes transcript language in summary
5. Maintains accuracy with original context

### Example 9: Video Without Transcript
```bash
/summarize "https://youtube.com/watch?v=notranscript" --no-transcript
```

**What it does**:
1. Detects transcript unavailable
2. Falls back to metadata analysis
3. Analyzes video description
4. Extracts information from comments (if helpful)
5. Generates limited summary noting constraints

**Output**:
```markdown
# Video Summary: Advanced Python Techniques

⚠️ **Note**: This video does not have transcripts available.
Summary generated from metadata and description only.

## From Video Description
This tutorial covers:
- List comprehensions and generators
- Decorators and context managers
- Async/await patterns
...
```

### Example 10: Live Stream or Long Video
```bash
/summarize "https://youtube.com/watch?v=livestream123" --format chapters
```

**What it does**:
1. Handles very long transcripts (2+ hours)
2. Breaks into logical segments
3. Generates overview + section summaries
4. Highlights most important segments
5. Creates navigation-friendly structure

## What It Does (Step-by-Step)

### Phase 1: Video Identification (5-10 seconds)
1. **Parse YouTube URL**
   - Extract video ID from various URL formats
   - Support full URLs, short URLs (youtu.be), bare IDs
   - Handle playlist URLs (prompt for batch processing)
   - Validate video ID format

2. **Fetch Video Metadata**
   - Title, description, duration
   - Channel name and information
   - Publish date, view count
   - Chapter markers (if provided by creator)
   - Tags and category

3. **Check Video Accessibility**
   - Verify video is public/accessible
   - Check for age restrictions
   - Detect if live stream or premiere
   - Note any access limitations

### Phase 2: Transcript Extraction (10-30 seconds)
4. **Attempt Transcript Retrieval**
   ```
   Priority order:
   1. Official manual transcript (highest quality)
   2. Auto-generated captions (decent quality)
   3. Community-contributed captions
   4. Fallback to description/metadata only
   ```

5. **Language Detection & Selection**
   - Auto-detect primary language
   - Use --language flag if specified
   - Check for multiple language options
   - Select best available transcript

6. **Transcript Processing**
   - Clean formatting and artifacts
   - Merge sentence fragments
   - Correct obvious transcription errors
   - Preserve timestamp associations
   - Normalize text (punctuation, capitalization)

### Phase 3: Content Analysis (20-60 seconds)
7. **Structural Analysis**
   - Identify video sections and chapters
   - Detect topic transitions
   - Map content hierarchy
   - Recognize intro/body/conclusion structure

8. **Key Point Extraction**
   - Identify main arguments and claims
   - Extract definitions and explanations
   - Capture important examples
   - Note statistics and data points
   - Flag actionable advice

9. **Topic Categorization**
   - Identify main topics discussed
   - Extract recurring themes
   - Map concept relationships
   - Tag with relevant keywords

10. **Resource Extraction**
    - Find mentioned books, tools, websites
    - Extract links from description
    - Note recommended resources
    - Capture code repositories or demos

11. **Quote Identification**
    - Identify memorable statements
    - Extract key insights worth quoting
    - Preserve timestamp context
    - Attribute properly

### Phase 4: Summary Generation (30-90 seconds)
12. **Executive Summary Creation**
    - Distill core message (2-3 sentences)
    - Capture primary value proposition
    - Identify target audience

13. **Format-Specific Content Generation**
    ```
    Detailed:
      - Full chapter breakdown
      - Comprehensive point coverage
      - All timestamps preserved

    Concise:
      - TL;DR summary
      - Top 5-10 key points
      - Quick value assessment

    Bullets:
      - Rapid-fire takeaways
      - Minimal context
      - Maximum density

    Chapters:
      - Section-by-section breakdown
      - Topic-organized content
      - Navigation-optimized

    Academic:
      - Structured course notes
      - Concept definitions
      - Learning objectives
    ```

14. **Metadata Compilation**
    - Video information section
    - Technical details
    - Link to original video
    - Summary generation date

15. **Quality Assurance**
    - Verify timestamp accuracy
    - Check for completeness
    - Validate quote accuracy
    - Ensure proper formatting

### Phase 5: Output & Storage (5-10 seconds)
16. **Document Formatting**
    - Apply Markdown structure
    - Add table of contents (if needed)
    - Format timestamps consistently
    - Embed links properly

17. **File Naming & Location**
    ```
    Default: docs/<sanitized-title>-summary.md
    Custom: User-specified path
    Playlist: summaries/<playlist-name>/video-NN-summary.md
    ```

18. **Save & Report**
    - Write summary to file
    - Report output location
    - Display brief preview (first few sections)
    - Provide direct link to file

## Integration Points

### Works With Other Agents
```bash
# Summarize → Research → Document
/summarize "https://youtube.com/watch?v=tutorial"
# Review summary
/research "topic from video" --format comprehensive
# Deep dive into specific topics

# Summarize → Memory → Retrieve
/summarize "https://youtube.com/watch?v=technique"
# task-memory-manager stores useful patterns
# Retrieve later when similar task arises

# Summarize → Code → Implement
/summarize "https://youtube.com/watch?v=coding-tutorial"
# Use code-craftsman to implement examples from summary
```

### Common Workflows
```bash
# Learn from video series
/summarize <playlist-url>
# Review all summaries
# Implement learnings in project

# Conference talk documentation
/summarize <talk-url> --format detailed --output docs/conferences/
# Share with team
# Reference in project documentation

# Quick research
/summarize <video-url> --format concise
# Scan key points
# Decide if full watch is valuable
```

## Output Location and Naming

### Default Location
```
<project-root>/docs/<video-title>-SUMMARY.md
```

### Naming Conventions
- Sanitize video title (remove special chars)
- Use hyphens for spaces
- Add `-SUMMARY` suffix
- Uppercase for emphasis
- Examples:
  - `ADVANCED-REACT-PATTERNS-SUMMARY.md`
  - `KUBERNETES-BEST-PRACTICES-SUMMARY.md`
  - `PYTHON-ASYNC-PROGRAMMING-SUMMARY.md`

### Custom Output
```bash
# Specify custom location
/summarize "url" --output custom-name.md

# Organize by topic
/summarize "url" --output docs/tutorials/react/lesson-01.md

# Playlist organization
summaries/<playlist-name>/
  ├── INDEX.md
  ├── 01-<title>-summary.md
  ├── 02-<title>-summary.md
  └── ...
```

## Configuration

### Default Settings
Can be configured in `.claude/settings.local.json`:

```json
{
  "youtube_summarizer": {
    "default_format": "detailed",
    "output_dir": "docs/",
    "transcript_cache": true,
    "timestamp_links": true,
    "auto_toc": true,
    "max_video_length": "10800",
    "language": "auto"
  }
}
```

### Permissions Required
```json
{
  "permissions": {
    "allow": [
      "WebFetch(*)",
      "WebSearch(youtube.com)",
      "Write(<project-path>/docs/**)",
      "Write(<project-path>/summaries/**)",
      "Bash(python:*)",
      "Bash(node:*)",
      "Read(<project-path>/**)",
      "Glob(*)",
      "Task(youtube-summarizer)"
    ]
  }
}
```

## Technical Implementation

### Transcript Extraction Methods

**Python Approach**:
```bash
pip install youtube-transcript-api
python scripts/extract_transcript.py <video-id>
```

**Node.js Approach**:
```bash
npm install youtube-transcript
node scripts/extract_transcript.js <video-id>
```

**Web Scraping Fallback**:
- Direct extraction from YouTube page HTML
- Used when API methods fail
- Lower reliability but works without API keys

### YouTube Data API Integration
```
Requires API Key:
  - Get from Google Cloud Console
  - Enable YouTube Data API v3
  - Set in environment: YOUTUBE_API_KEY

Quota Limits:
  - 10,000 units per day (default)
  - Metadata fetch: ~3 units
  - Plan usage accordingly for batch operations
```

## Limitations & Troubleshooting

### Common Issues

#### No Transcript Available
```
Symptoms: Video has no captions/subtitles
Solutions:
  - Use --no-transcript flag for metadata-only summary
  - Contact video creator about adding captions
  - Use automatic speech recognition tools separately
```

#### Private or Unavailable Video
```
Symptoms: Can't access video content
Solutions:
  - Verify video URL is correct
  - Check if video is private/unlisted
  - Confirm video hasn't been deleted
```

#### API Rate Limiting
```
Symptoms: Multiple requests failing
Solutions:
  - Implement caching (enabled by default)
  - Reduce batch processing size
  - Use delays between requests
  - Consider API key quota limits
```

#### Poor Auto-Caption Quality
```
Symptoms: Summary contains nonsense or errors
Solutions:
  - Note transcript quality in summary
  - Manually correct critical errors
  - Focus on high-confidence segments
  - Wait for manual captions if important
```

#### Very Long Videos (>3 hours)
```
Symptoms: Processing takes very long or times out
Solutions:
  - Use --format chapters for segmented approach
  - Process in multiple passes
  - Focus on key sections
  - Consider splitting into multiple summaries
```

### Debugging

```bash
# Test transcript extraction
/summarize "video-url" --verbose

# Check API connectivity
/summarize "dQw4w9WgXcQ" --test

# Validate output format
/summarize "video-url" --format detailed --dry-run
```

## Tips for Best Results

### Choosing the Right Format

```bash
# Long tutorial or lecture → detailed
/summarize "url" --format detailed

# Quick decision making → concise
/summarize "url" --format concise

# Action-oriented content → bullets
/summarize "url" --format bullets

# Interview or discussion → chapters
/summarize "url" --format chapters

# Learning/course content → academic
/summarize "url" --format academic
```

### Optimizing Summary Quality

1. **Verify transcript quality**: Check auto-generated vs manual
2. **Use chapter markers**: Enable --timestamps for navigation
3. **Specify language**: Use --language for non-English content
4. **Custom output**: Organize summaries by project structure
5. **Review and edit**: Summaries are starting points, refine as needed

### Batch Processing Best Practices

```bash
# Process playlist in order
/summarize "playlist-url"

# Set output directory for organization
/summarize "playlist-url" --output summaries/course-name/

# Use concise format for quick playlist overview
/summarize "playlist-url" --format concise

# Add delays for API rate limiting
(Automatically handled by agent)
```

## Related Commands

- `/yt-analyze` - Deep analysis of video content (topics, sentiment)
- `/research` - Comprehensive research on video topics
- `/help` - List all available commands

## Version History

- v1.0: Initial YouTube summarizer with transcript extraction
- v1.1: Added multiple format options
- v1.2: Playlist/batch processing support
- v1.3: Enhanced non-English video support
- v1.4: Improved academic note format

## Philosophy

This command transforms passive video consumption into active knowledge acquisition.

Instead of spending hours watching videos:
- Extract key insights in minutes
- Navigate directly to relevant sections
- Build searchable knowledge base
- Share learnings efficiently
- Reference information quickly

The `/summarize` command democratizes video content by making it:
- **Accessible**: Read instead of watch
- **Searchable**: Find specific information easily
- **Shareable**: Send summaries instead of links
- **Actionable**: Extract practical steps
- **Referenceable**: Cite with timestamps

---

**Ready to summarize?**

```bash
# Start your first YouTube summary
/summarize "your-youtube-url-here"
```

The youtube-summarizer agent will extract the transcript, analyze the content, and generate a comprehensive summary in your project's documentation folder.

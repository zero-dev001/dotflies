# HTTP Tools: curl and wget

> The two foundational command-line HTTP clients -- curl for precision API work and scripting, wget for recursive downloads and mirroring.

## Your Setup

Both tools are installed explicitly via Homebrew in the master Brewfile:

```ruby
brew "curl"
brew "wget"
```

The Homebrew versions are preferred over the macOS system `curl` because they include more recent TLS libraries, HTTP/2 and HTTP/3 support, and additional protocols. After installation, Homebrew's `curl` takes precedence in your PATH.

These tools pair naturally with **jq** (covered in the next chapter) for working with JSON APIs, and with **aria2** for high-speed parallel downloads.

## Core Concepts

### curl -- Transfer Data with URLs

curl is a tool for transferring data using URL syntax. It supports dozens of protocols (HTTP, HTTPS, FTP, SFTP, SCP, and more) but is most commonly used for HTTP requests. curl sends a single request and prints the response to stdout, making it ideal for API exploration, webhook testing, and scripting.

Key design principles:
- Everything goes to stdout by default (use `-o` to save to a file)
- Silent about progress unless you ask for verbosity (or ask it to be silent with `-s`)
- Follows the Unix philosophy -- combine with pipes, redirects, and other tools

### wget -- Non-Interactive Network Downloader

wget is designed for downloading files. Unlike curl, it defaults to saving to a file (not stdout), supports recursive downloading, and can resume interrupted transfers. wget is the better choice when you want to mirror a website or download a large set of files.

## Essential Commands -- curl

| Command | Purpose |
|---|---|
| `curl URL` | GET request, print response to stdout |
| `curl -s URL` | Silent mode -- suppress progress bar |
| `curl -o file URL` | Save response to a named file |
| `curl -O URL` | Save with the remote filename |
| `curl -I URL` | Fetch HTTP headers only (HEAD request) |
| `curl -v URL` | Verbose output showing full request/response |
| `curl -L URL` | Follow HTTP redirects |
| `curl -X POST URL` | Send a POST request |
| `curl -X PUT URL` | Send a PUT request |
| `curl -X DELETE URL` | Send a DELETE request |
| `curl -d '{"key":"val"}' URL` | Send data in request body |
| `curl -d @file.json URL` | Send file contents as request body |
| `curl -H "Content-Type: application/json" URL` | Set a request header |
| `curl -H "Authorization: Bearer TOKEN" URL` | Authenticate with a bearer token |
| `curl -u user:pass URL` | HTTP basic authentication |
| `curl -b cookies.txt URL` | Send cookies from a file |
| `curl -c cookies.txt URL` | Save received cookies to a file |
| `curl -C - -O URL` | Resume an interrupted download |
| `curl --connect-timeout 5 --max-time 10 URL` | Set connection and total timeouts |

## Essential Commands -- wget

| Command | Purpose |
|---|---|
| `wget URL` | Download a file (saves with remote name) |
| `wget -O name URL` | Download and save with a custom filename |
| `wget -c URL` | Resume an interrupted download |
| `wget -b URL` | Download in the background |
| `wget -r URL` | Recursive download (follow links) |
| `wget -r -l 2 URL` | Recursive download, limit depth to 2 levels |
| `wget -m URL` | Mirror a website (recursive + timestamps + infinite depth) |
| `wget -i urls.txt` | Download all URLs listed in a file |
| `wget -q URL` | Quiet mode -- no output |
| `wget --limit-rate=1m URL` | Limit download speed to 1 MB/s |
| `wget --no-check-certificate URL` | Skip SSL certificate verification |
| `wget -P /path/to/dir URL` | Save downloaded file to a specific directory |

## Practical Recipes

### GET a JSON API and pretty-print with jq

```bash
curl -s https://api.github.com/users/octocat | jq '.'
```

The `-s` flag silences the progress bar so only clean JSON reaches jq.

### POST JSON to an API

```bash
curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"name": "new-repo", "private": true}' \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  https://api.github.com/user/repos | jq '.'
```

### Upload a file with a multipart form

```bash
curl -X POST -F "file=@document.pdf" -F "name=upload-test" \
  https://example.com/upload
```

The `-F` flag creates a `multipart/form-data` request, which is how HTML file upload forms work.

### Check if a URL is reachable

```bash
curl -s -o /dev/null -w "%{http_code}" https://example.com
```

This prints only the HTTP status code (e.g., `200`, `404`, `301`). The `-o /dev/null` discards the body, and `-w` formats the output.

### Measure response time

```bash
curl -s -o /dev/null -w "DNS: %{time_namelookup}s\nConnect: %{time_connect}s\nTLS: %{time_appconnect}s\nTotal: %{time_total}s\n" https://example.com
```

The `-w` flag supports many timing variables that break down where latency is spent.

### Download with a progress bar

```bash
curl -# -O https://example.com/large-file.tar.gz
```

The `-#` flag replaces the default statistics with a simple progress bar.

### Mirror a website for offline reading

```bash
wget -m -k -p https://example.com
```

The flags mean: `-m` mirror (recursive + timestamps), `-k` convert links for local viewing, `-p` download page requisites (CSS, images).

### Download all files of a type from a page

```bash
wget -r -l 1 -A "*.pdf" https://example.com/papers/
```

The `-A` flag accepts only files matching the pattern, and `-l 1` limits recursion depth.

### Retry a flaky download

```bash
wget -c --tries=10 --waitretry=30 https://example.com/large-file.iso
```

wget will retry up to 10 times, waiting 30 seconds between attempts, and resuming from where it left off each time.

## Advanced Usage

### curl with a Configuration File

For repeated API work, store common options in a file:

```
# ~/.curlrc
--silent
--show-error
--location
--connect-timeout 10
--max-time 30
```

curl reads `~/.curlrc` automatically. Override any setting with explicit flags.

### Sending Multiple curl Requests in Parallel

curl 7.66+ supports `--parallel` for sending multiple requests simultaneously:

```bash
curl --parallel --parallel-max 5 \
  -O https://example.com/file1.tar.gz \
  -O https://example.com/file2.tar.gz \
  -O https://example.com/file3.tar.gz
```

### Inspecting and Debugging TLS

```bash
# Show full TLS handshake details
curl -v --trace-ascii /dev/stderr https://example.com 2>&1 | head -40

# Check certificate expiry
curl -s -v https://example.com 2>&1 | grep "expire date"
```

### Scripting Patterns with curl

A common pattern for API scripts: check the status code and handle errors.

```bash
response=$(curl -s -w "\n%{http_code}" https://api.example.com/data)
body=$(echo "$response" | head -n -1)
status=$(echo "$response" | tail -n 1)

if [ "$status" -ne 200 ]; then
  echo "Error: HTTP $status"
  echo "$body" | jq '.message'
  exit 1
fi

echo "$body" | jq '.'
```

### When to Use Which Tool

| Scenario | Preferred Tool |
|---|---|
| API requests (GET, POST, PUT, DELETE) | curl |
| Downloading a single file | Either (curl -O or wget) |
| Resuming a large download | wget -c |
| Recursive site download / mirroring | wget -m |
| Custom headers and authentication | curl |
| Scripting HTTP interactions | curl |
| Batch downloading from a URL list | wget -i |
| High-speed parallel downloads | aria2 (see pandoc/ffmpeg chapter) |

\newpage

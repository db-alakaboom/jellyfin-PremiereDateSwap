# Specify the Jellyfin API endpoint for fetching user sessions
$apiEndpoint = "https://YOURDOMAIN/Sessions?api_key=YOURAPIKEYHERE"

# Get the directory where the script is located
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Define log file path in the same directory as the script
$logFilePath = Join-Path -Path $scriptDirectory -ChildPath "log.txt"

# Log levels
$logLevels = @{
    Info    = "INFO"
    Warning = "WARNING"
    Error   = "ERROR"
}

# Function to log messages
function Log-Message {
    param (
        [string]$message,
        [string]$level = "INFO"
    )

    # Get current timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Create log entry
    $logEntry = "$timestamp - [$level] - $message"

    # Append log entry to log file
    Add-Content -Path $logFilePath -Value $logEntry

    # Output log entry to console
    Write-Output $logEntry
}

Log-Message "Script starting..." -level $logLevels.Info

# Make a request to the API endpoint to get information about user sessions
Log-Message "Making a request to local Jellyfin API to get information about user sessions..." -level $logLevels.Info
$activeSessions = Invoke-RestMethod -Uri $apiEndpoint -Method Get

# Check if there are any active sessions (logged-in users)
if ($activeSessions.Count -gt 0) {
    Log-Message "Jellyfin reporting active user sessions." -level $logLevels.Info
    
    # Check if any session has "NowPlayingItem" in the JSON response
    $anySessionWithNowPlayingItem = $activeSessions | Where-Object { $_ -match "NowPlayingItem" }

    if ($anySessionWithNowPlayingItem) {
        Log-Message "Found active user session with 'NowPlayingItem' in the JSON response. Exiting script to avoid issues." -level $logLevels.Warning
        exit
    } else {
        Log-Message "Did not find active user sessions with 'NowPlayingItem' in the JSON response. Proceeding with the script." -level $logLevels.Info
    }
} else {
    Log-Message "No active user sessions reported. Proceeding with the script." -level $logLevels.Info
}

#If no issues, continues to stop the server
Log-Message "Stopping Jellyfin service..." -level $logLevels.Info
$service = Get-Service -DisplayName "Jellyfin Server"

try {
    if ($service.Status -eq 'Running') {
        Stop-Service -DisplayName "Jellyfin Server" -Force 
        # Wait for the service to stop
        Start-Sleep -Seconds 10 
    }
} catch {
    $errorMessage = "Error stopping Jellyfin service: $_"
    Log-Message $errorMessage -level $logLevels.Error
    throw $errorMessage
}

# Run SQL commands
$databasePath = "C:\ProgramData\Jellyfin\Server\data\library.db" 

# Wait for the database lock to be released
for ($i = 1; $i -le 10; $i++) {
    try {
        & "C:\your\path\to\sqlite3.exe" $databasePath "PRAGMA locking_mode = NORMAL;"
        break
    } catch {
        Log-Message "Waiting for database lock to be released... (Attempt $i)" -level $logLevels.Info
        Start-Sleep -Seconds 5
    }
}

# Define SQL commands
$sqlCommands = @(
    'UPDATE TypedBaseItems SET PremiereDate = NULL WHERE PremiereDate = ''0001-01-01 00:00:00Z'';',
    'UPDATE TypedBaseItems SET DateCreated = PremiereDate WHERE type = ''MediaBrowser.Controller.Entities.Movies.Movie'' AND PremiereDate IS NOT NULL;',
    'UPDATE TypedBaseItems SET DateCreated = PremiereDate WHERE type LIKE ''MediaBrowser.Controller.Entities.TV.%'' AND PremiereDate IS NOT NULL;',
    'VACUUM;'
)

# Execute SQL commands
foreach ($sqlCommand in $sqlCommands) {
    try {
        Log-Message "Executing SQL command: $sqlCommand" -level $logLevels.Info
        & "C:\your\path\to\sqlite3.exe" $databasePath $sqlCommand
    } catch {
        $errorMessage = "Error executing SQL command: $sqlCommand - $_"
        Log-Message $errorMessage -level $logLevels.Error
        throw $errorMessage
    }
}

# Close the SQLite database
try {
    Log-Message "Closing SQLite database..." -level $logLevels.Info
    & "C:\your\path\to\sqlite3.exe" $databasePath ".exit"
} catch {
    $errorMessage = "Error closing SQLite database: $_"
    Log-Message $errorMessage -level $logLevels.Error
    throw $errorMessage
}

Log-Message "Starting Jellyfin service..." -level $logLevels.Info
try {
    Start-Service -DisplayName "Jellyfin Server"
} catch {
    $errorMessage = "Error starting Jellyfin service: $_"
    Log-Message $errorMessage -level $logLevels.Error
    throw $errorMessage
}

Log-Message "Script completed." -level $logLevels.Info

# Stop Jellyfin service
Write-Host "Stopping Jellyfin service..."
$service = Get-Service -DisplayName "Jellyfin Server"

try {
    if ($service.Status -eq 'Running') {
        Stop-Service -DisplayName "Jellyfin Server" -Force 

        # Wait for the service to stop
        Start-Sleep -Seconds 10  # Adjust the sleep duration as needed
    }
} catch {
    Write-Host "Error stopping Jellyfin service: $_"
    throw "Stopping Jellyfin service failed."
}

# Run SQL commands
$databasePath = "C:\ProgramData\Jellyfin\YOURUSERNAMEHERE\data\library.db" 

# Wait for the database lock to be released
for ($i = 1; $i -le 10; $i++) {
    try {
        & "C:\path\to\sqlite3.exe" $databasePath "PRAGMA locking_mode = NORMAL;"
        break
    } catch {
        Write-Host "Waiting for database lock to be released... (Attempt $i)"
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
        Write-Host "Executing SQL command: $sqlCommand"
        & "C:\path\to\sqlite3.exe" $databasePath $sqlCommand
    } catch {
        Write-Host "Error executing SQL command: $sqlCommand - $_"
        throw "SQL command execution failed."
    }
}

# Close the SQLite database
try {
    Write-Host "Closing SQLite database..."
    & "C:\path\to\sqlite3.exe" $databasePath ".exit"
} catch {
    Write-Host "Error closing SQLite database: $_"
    throw "Closing SQLite database failed."
}

# Start Jellyfin service
Write-Host "Starting Jellyfin service..."
try {
    Start-Service -DisplayName "Jellyfin Server"
} catch {
    Write-Host "Error starting Jellyfin service: $_"
    throw "Starting Jellyfin service failed."
}

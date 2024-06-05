local lfs = require "lfs"

-- Function to load existing file timestamps
local function load_file_timestamps(filename)
    local file_timestamps = {}
    local file = io.open(filename, "r")
    if not file then return file_timestamps end
    for line in file:lines() do
        local filepath, timestamp = line:match("([^,]+),([^,]+)")
        if filepath and timestamp then
            file_timestamps[filepath] = timestamp
        end
    end
    file:close()
    return file_timestamps
end

-- Function to save current file timestamps
local function save_file_timestamps(filename, file_timestamps)
    local file = io.open(filename, "w")
    for filepath, timestamp in pairs(file_timestamps) do
        file:write(filepath .. "," .. timestamp .. "\n")
    end
    file:close()
end

-- Main function to monitor files for changes
local function monitor_files(file_list, timestamp_file)
    local file_timestamps = load_file_timestamps(timestamp_file)
    local new_file_timestamps = {}

    for _, filepath in ipairs(file_list) do
        local attr = lfs.attributes(filepath)
        if attr then
            local new_timestamp = attr.modification
            new_file_timestamps[filepath] = new_timestamp
            if file_timestamps[filepath] and file_timestamps[filepath] ~= tostring(new_timestamp) then
                print("File changed: " .. filepath)
            elseif not file_timestamps[filepath] then
                print("New file detected: " .. filepath)
            end
        else
            print("Failed to read file: " .. filepath)
        end
    end

    save_file_timestamps(timestamp_file, new_file_timestamps)
end

-- List of files to monitor (add your file paths here)
local files_to_monitor = {
    "file1.txt",
    "file2.txt",
    "file3.txt"
}

-- File to store file timestamps
local timestamp_storage_file = "file_timestamps.txt"

-- Monitor files for changes
monitor_files(files_to_monitor, timestamp_storage_file)


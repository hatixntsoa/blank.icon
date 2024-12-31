# Clean Shortcut Icon Script for Windows

This script allows you to remove the default shortcut arrow icon from Windows and replace it with a custom icon, such as a Unix-style clean icon. The script makes a registry modification to update the shortcut icon for a more streamlined look.

## Features
- Removes the default shortcut arrow from icons.
- Replaces it with a custom icon (`blank.ico`).
- Works by modifying the registry key for **Windows Explorer**.
- Offers a clean, Unix-like look for your desktop shortcuts.

## Prerequisites
- **Windows 7 or later**: The script is designed to work on modern Windows versions.
- **Administrator privileges**: The script requires elevated privileges to modify the system registry.
- **Git**: Ensure that **Git** is installed for the cloning process.

## Installation

### Step 1: Clone the Repository
First, clone the repository from GitHub to get the script.

1. Open **Command Prompt** or **PowerShell**.
2. Run the following command to clone the repository:
   ```bash
   git clone https://github.com/h471x/blank_icon.git
   ```
3. Navigate to the `blank_icon` directory:
   ```bash
   cd blank_icon
   ```

### Step 2: Run the Script
#### From Command Line
1. Ensure you are in the `blank_icon` directory (where `scripts\blank.bat` is located).
2. Run the following command to execute the batch file as an administrator:
   ```batch
   runas /user:Administrator ".\scripts\blank.bat"
   ```
3. You will be prompted to enter the full path to the `blank.ico` file. If the `.ico` file is located in the same directory as the script, the script will automatically detect it.

#### From Windows Explorer
1. Navigate to the `scripts` folder inside the `blank_icon` directory.
2. Right-click the `blank.bat` file and select **Run as administrator** from the context menu.
3. Follow the on-screen prompts to enter the path to the custom `.ico` file (if necessary).

### Step 3: Restart Windows Explorer
The script will automatically restart **Windows Explorer** to apply the changes. This will remove the shortcut arrows and apply the custom icon.

## How It Works
- The script checks if the `blank.ico` file is located in the same directory as the batch script.
- If the `.ico` file is not found, it prompts the user to provide the full path to the `blank.ico` file.
- The registry key for **Shell Icons** is updated to associate the `blank.ico` with all shortcut icons, removing the default shortcut arrows and replacing them with a clean Unix-like icon.

## Reverting the Changes
If you want to revert the changes and restore the default shortcut arrow icon, you can use the `revert.bat` script.

### Step 1: Run the Revert Script
1. Navigate to the `scripts` folder inside the `blank_icon` directory.
2. Right-click the `revert.bat` file and select **Run as administrator** from the context menu.
3. The script will remove the custom icon and restore the default Windows shortcut arrow.

Alternatively, you can run the `revert.bat` script from the command line using the following command:
```batch
runas /user:Administrator ".\scripts\revert.bat"
```

### How It Works
- The `revert.bat` script deletes the registry entry for the custom shortcut icon.
- It then restarts **Windows Explorer** to apply the changes and restore the default icons.

## Notes
- Ensure the `blank.ico` file exists and is named exactly `blank.ico` before running the script.
- The script requires **administrator** privileges to make changes to the Windows registry.
- To restore the default icon after running the `blank.bat` script, you can use the `revert.bat` script as described above.
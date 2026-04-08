# GitHub Copilot in Visual Studio Code – Instructions Guide

This guide explains how to install, configure, and effectively use GitHub Copilot in Visual Studio Code.

---

## Prerequisites

Before you begin, ensure you have:

- Visual Studio Code installed
- A GitHub account
- Active GitHub Copilot subscription (or trial)
- Internet connection

---

## Install GitHub Copilot Extension

1. Open Visual Studio Code
2. Go to Extensions (`Ctrl + Shift + X`)
3. Search for **GitHub Copilot**
4. Click **Install**

---

## Sign In to GitHub

1. After installation, click **Sign in to GitHub**
2. A browser window will open
3. Authorize Visual Studio Code
4. Return to VS Code once authentication is complete

---

## Enable Copilot

Copilot is usually enabled automatically. If not:

1. Open Command Palette (`Ctrl + Shift + P`)
2. Type: `Copilot: Enable`
3. Select the option

---

## Basic Usage

### Inline Suggestions

- Start typing code
- Copilot will suggest completions automatically
- Press `Tab` to accept
- Press `Esc` to dismiss

---

### Trigger Suggestions Manually

- Press: `Ctrl + Enter`
- This opens multiple suggestions in a panel

---

### Cycle Through Suggestions

- `Alt + ]` → Next suggestion
- `Alt + [` → Previous suggestion

---

## Writing Better Prompts

Copilot works best with clear context.

### Example (Terraform)

```hcl
# Create an Azure resource group with tags
```

### Example (Python)

```python
# Function to validate email using regex
```

Tips:
- Use comments to describe intent
- Be specific about inputs/outputs
- Include examples if possible

---

## Copilot Chat (Optional)

If installed (Copilot Chat extension):

- Open Chat panel
- Ask questions like:
  - "Explain this code"
  - "Optimize this function"
  - "Generate Terraform for Azure VM"

---

## Configuration

Open Settings (`Ctrl + ,`) and search for **Copilot**.

Useful settings:

- Enable/disable inline suggestions
- Language-specific enablement
- Auto-trigger suggestions

Example (`settings.json`):

```json
{
  "github.copilot.enable": {
    "*": true,
    "plaintext": false,
    "markdown": true
  }
}
```

---

## Best Practices

- Always review generated code
- Do not blindly trust suggestions
- Ensure security and compliance
- Use version control (Git)

---

## Troubleshooting

### Copilot Not Working

- Check login status
- Restart VS Code
- Reinstall extension

### No Suggestions Appearing

- Ensure file type is supported
- Check Copilot is enabled
- Verify internet connection

---

## Useful Commands

- `Copilot: Enable`
- `Copilot: Disable`
- `Copilot: Open Panel`

---

## Summary

GitHub Copilot enhances productivity by providing AI-powered code suggestions directly in your editor. With proper usage and validation, it can significantly speed up development workflows.

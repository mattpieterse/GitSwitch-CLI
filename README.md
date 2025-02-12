# GitSwitch CLI

GitSwitch CLI is a lightweight, PowerShell-based solution designed to simplify the management of multiple Git and GitHub profiles on a single machine. 

Tailored for developers who balance personal and professional projects (and students!), GitSwitch CLI enables seamless transitions between home and work profiles with a single command. Eliminate the hassle of manual configuration and enhance your productivity with an efficient, command-line-driven approach to profile management.

**Key Features:**

- Quickly switch between multiple home and work profiles.
- Automatically update Git config information and GitHub credentials.
- Enables signing-profiles to verify your commits.
- Lightweight and easy to integrate into your workflow.
- Open-source and fully customisable to fit your needs.

## Getting started

**Important:** *The current version of this script assumes that you have created, registered, and set SSH keys for each GitHub account, and that the same SSH keys are used for both authentication and for signing (verifying) commits. This will be updated in later versions.*

1. Clone or download this repository to a convenient (permanent) location on your machine.
2. Ensure that your SSH profiles are created and registered on your machine and on GitHub.
3. Create your `config.json` file next to the script file as seen below:

```
{
    "accounts": {
        "home": {
            "name": "<GITHUB_USERNAME>",
            "email": "<GITHUB_NOREPLY_EMAIL>",
            "signingkey": "~/.ssh/id_ed25519_github_home.pub",
            "sshCommand": "ssh -i ~/.ssh/id_ed25519_github_home"
        },
        "work": {
            "name": "<GITHUB_USERNAME>",
            "email": "<GITHUB_NOREPLY_EMAIL>",
            "signingkey": "~/.ssh/id_ed25519_github_work.pub",
            "sshCommand": "ssh -i ~/.ssh/id_ed25519_github_work"
        }
    }
}
```

4. Execute the script by opening a terminal in the `GitSwitch-CLI/` directory and running the following command:

```
./gitswitcher.ps1 -Account home
```

```
./gitswitcher.ps1 -Account work
```

If you ran both commands and were successful, the script is fully operational. Happy coding!
# Attribution

North Forge - Hermes Edition (Kyocera Edition v21.8) is part of the North Forge project. Created and maintained by Kenneth C. Walker Jr. - Senior Technical Support Engineer, TSC.

None of this exists without Nous Research's work, and this file exists to say so plainly, not just to satisfy a license requirement.

**North Forge - Hermes Edition runs on top of Hermes Agent**, an open-source AI agent framework built by Nous Research (https://hermes-agent.nousresearch.com/), released under the MIT License. Hermes provides the actual engine underneath everything here: the persistent memory, the skills system, the multi-provider model support, the terminal and messaging interfaces - the parts that took real engineering to build and that this project would have had no practical way to build from scratch. What's added on top - the North Forge context file, the Kyocera-specific skills, the mode-toggle system, the skin, the setup scripts - is a thin layer of content and configuration by comparison.

Everything in this repo is that thin layer. The engine itself lives untouched in `kwalker7631/north-forge-agent` (a mirror of NousResearch/hermes-agent) and carries its own MIT license text, which we do not modify or strip.

The "North Forge" name, skin, and Kyocera-specific content in this repo are not affiliated with or endorsed by Nous Research.

For anyone reading this who wants to know what Hermes actually is beyond what this repo uses: https://github.com/NousResearch/hermes-agent and https://hermes-agent.nousresearch.com/docs/ are the real source. This project is a downstream user of their work, not a fork with ambitions of its own.

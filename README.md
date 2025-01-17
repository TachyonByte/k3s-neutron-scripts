<img src="https://tachyonbyte.s3.ap-south-1.amazonaws.com/static/assets/img/fullwhite.png" alt="TachyonByte" width="200"/>

[![Last Commit](https://img.shields.io/github/last-commit/TachyonByte/k3s-neutron-scripts?style=for-the-badge&color=white)](https://github.com/TachyonByte/k3s-neutron-scripts/commits/main)
[![License](https://img.shields.io/github/license/TachyonByte/k3s-neutron-scripts?style=for-the-badge&color=white)](https://github.com/TachyonByte/k3s-neutron-scripts/blob/main/LICENSE)

# k3s-neutron-scripts

A Bash script for automating the installation and setup of K3s (Lightweight Kubernetes) along with useful tools like kubectl, Helm, and k9s.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Features

- Automated installation of K3s on the host machine
- Setup of kubectl for both host and client machines
- Installation of Helm for package management
- Installation of k9s for terminal-based UI
- Cleanup functionality to remove all changes made by the script
- Colorful output with progress indicators
- Support for both Debian and Red Hat based systems

## Requirements

- Linux system (Debian or Red Hat based)
- Internet connection
- Sudo privileges 

## Installation

```bash
1. Clone the repository:
git clone https://github.com/TachyonByte/k3s-neutron-scripts

2. Navigate to the cloned directory:
cd k3s-neutron-scripts

3. Make the script executable:
chmod +x k3s-neutron.sh

4. Run the script:
./k3s-neutron.sh
```

## Usage

This script is intended for testing purposes only and should not be used in production environments. It provides an interactive menu for easy navigation:
```bash
==============================================
Welcome to
************
    _   __________  ____________  ____  _   __
   / | / / ____/ / / /_  __/ __ \/ __ \/ | / /
  /  |/ / __/ / / / / / / / /_/ / / / /  |/ / 
 / /|  / /___/ /_/ / / / / _, _/ /_/ / /|  /  
/_/ |_/_____/\____/ /_/ /_/ |_|\____/_/ |_/   
                                              
               __  _____     
              / /_|__  /_____
             / //_//_ </ ___/
            / ,< ___/ (__  ) 
           /_/|_/____/____/  
                             
                                      ********
                                      Script 
==============================================
      Made with ❤️ by TachyonByte Technologies
---------------------------------------------
    Automating installation and setup        
---------------------------------------------
_________________________________________
            Setup Script Menu
_________________________________________
1. Host Setup
2. Client Setup
3. Cleanup script
4. Exit
_________________________________________
Enter your choice [1-4]: 

```
Choose the appropriate option based on your needs:

Host Setup -
This option sets up K3s on the current machine and configures kubectl. It's suitable for testing K3s installation and basic functionality.

Client Setup -
Use this option on remote machines to configure kubectl and install additional tools. This can help test multi-node K3s setups.

Cleanup Script -
This script removes all changes made by the test installation, including K3s installation. It's useful for resetting your environment between test runs.


<div style="background-color:#318CE7; padding: 10px;"><details ontoggle="showNote()" open>
<summary>Important Note</summary>
<p>This script is for testing purposes only. Do not use this script in production environments. Always backup important data before running the script. The script may require sudo privileges for certain operations.</p>
</details>

</div>

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## Contributors



<!---
npx contributor-faces --exclude "*bot*" --limit 70 --repo "https://github.com/amplication/amplication"

change the height and width for each of the contributors from 80 to 50.
--->
[//]: contributor-faces
<a href="https://github.com/purvesh0110"><img src="https://avatars.githubusercontent.com/u/97841283?u=48784c3ae6e0e5d09e152beec1e0df2e9ff7ae42&v=4" title="purvesh-wakode" width="50" height="50"></a>
 
 ## License

[GPL-3.0 license](https://github.com/TachyonByte/k3s-neutron-scripts?tab=GPL-3.0-1-ov-file#readme)


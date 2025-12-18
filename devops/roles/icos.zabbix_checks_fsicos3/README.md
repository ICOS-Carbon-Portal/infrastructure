# Ansible Role: icos.zabbix_custom_checks

This Ansible role deploys custom Zabbix monitoring checks to specific hosts (fsicos2 and fsicos3).

## Role Structure

```
icos.zabbix_custom_checks/
├── defaults/
│   └── main.yml           # Default variables
├── handlers/
│   └── main.yml           # Service restart handlers
├── tasks/
│   └── main.yml           # Main tasks with blocks and tags
├── files/
│   ├── fsicos2/           # Files specific to fsicos2
│   │   ├── check_*.sh     # Shell check scripts
│   │   ├── check_*.py     # Python check scripts
│   │   ├── custom_*.conf  # Custom configuration files
│   │   └── zabbix         # Sudoers file (optional)
│   └── fsicos3/           # Files specific to fsicos3
│       ├── check_*.sh     # Shell check scripts
│       ├── check_*.py     # Python check scripts
│       ├── custom_*.conf  # Custom configuration files
│       └── zabbix         # Sudoers file (optional)
└── README.md              # This file
```

## Variables

The following variables are defined in `defaults/main.yml`:

- `zabbix_scripts_dir`: Directory for Zabbix scripts (default: `/etc/zabbix/scripts`)
- `zabbix_custom_dir`: Directory for custom configurations (default: `/etc/zabbix/zabbix_agent2.d`)
- `zabbix_sudoers_dir`: Directory for sudoers files (default: `/etc/sudoers.d`)
- `zabbix_agent_service`: Zabbix agent service name (default: `zabbix-agent2`)

## Tags

The role uses the following tags for selective deployment:

- `fsicos2-custom`: Deploy only fsicos2 custom checks
- `fsicos3-custom`: Deploy only fsicos3 custom checks
- `zabbix-custom`: Deploy all custom checks

## Usage

### Deploy only to fsicos2
```
just play server-fsicos2 -t fsicos2-custom -D
```

### Deploy only to fsicos3
```
just play server-fsicos3 -t fsicos3-custom -D
```

## Features

1. **Automatic directory creation**: Creates necessary Zabbix directories if they don't exist
2. **Proper file permissions**: Sets correct ownership and permissions for all files
3. **Conditional deployment**: Uses blocks with conditions to deploy files only to appropriate hosts
4. **Sudoers validation**: Validates sudoers files before deployment
5. **Service restart**: Automatically restarts Zabbix agent after file changes
6. **Tag-based deployment**: Allows selective deployment using tags

## Notes

- The role checks if the host is named 'fsicos2' or 'fsicos3' or belongs to corresponding groups
- All check scripts are made executable (mode 0755)
- Configuration files are deployed with read permissions (mode 0644)
- The Zabbix agent service is restarted only when files are changed


# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.2.x   | :white_check_mark: |
| 1.1.x   | :white_check_mark: |
| < 1.1   | :x:                |

## Reporting a Vulnerability

Please report security vulnerabilities to: security@muhittincamdali.com

**Do NOT open public issues for security vulnerabilities.**

## Security Considerations

SwiftCodeGen reads and writes files. Security considerations:

### File System Access
- Only reads files from specified input paths
- Only writes to specified output paths
- Validates file paths before access

### Code Generation
- Generated code is deterministic
- No network access during generation
- No code execution from input

## Best Practices

```yaml
# swiftcodegen.yml
input:
  - ./Sources  # Restrict to specific directories
output:
  - ./Generated
  
# Don't generate into system directories
# Don't read from untrusted sources
```

Thank you for helping keep SwiftCodeGen secure! 🛡️

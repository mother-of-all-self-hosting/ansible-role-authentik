# Authentik Ansible Role

[authentik](https://goauthentik.io/) is an open-source Identity Provider focused on flexibility and versatility. This role can install authentik for you.

- with everything run in [Docker](https://www.docker.com/) containers
- powered by [the official authentik container images](https://ghcr.io/goauthentik/server)


## Installing

To configure and install authentik on your own server(s), you should use a playbook like [Mother of all self-hosting](https://github.com/mother-of-all-self-hosting/mash-playbook) or write your own.


## Configuration Examples

### Basic Configuration

```yaml
# Required configuration
authentik_hostname: 'auth.example.com'
authentik_secret_key: 'your-secret-key-here'

# Database configuration
authentik_database_hostname: 'postgres.example.com'
authentik_database_username: 'authentik'
authentik_database_password: 'your-database-password'

# Redis configuration
authentik_config_redis_hostname: 'redis.example.com'
```

### Custom Theme Configuration

You can customize Authentik's appearance using CSS. Here's an example that creates a purple theme with a custom background:

```yaml
authentik_custom_css: |
  /*** global ***/
  :root {
    --ak-accent: #3A244A;
    --ak-flow-background: url(https://picsum.photos/1920/1080) !important;
    --pf-global--primary-color--100: #70468E;
    --pf-global--primary-color--200: #55356c;
    --pf-global--primary-color--400: var(--ak-accent);
  }
  .pf-c-background-image {
    --pf-c-background-image--Filter: none;
    --ak-flow-background: inherit !important;
  }
```

This configuration:
- Sets a dark purple accent color
- Adds a random background image from Picsum Photos
- Customizes the primary color palette to match the purple theme

Note: When using custom backgrounds, ensure the URLs are accessible from your Authentik server.

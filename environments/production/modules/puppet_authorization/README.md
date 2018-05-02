# puppet_authorization

#### Table of Contents


1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with puppet_authorization](#setup)
    * [Beginning with puppet_authorization](#beginning-with-puppet_authorization)
3. [Usage - Configuration options and additional functionality](#usage)
    * [Add a rule](#add-a-rule)
    * [Delete a rule](#delete-a-rule)
    * [Configure the catalog endpoint](#configure-the-catalog-endpoint)
    * [Trigger rule changes](#trigger-rule-changes)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)


## Module Description

The puppet_authorization module generates or changes the auth.conf file using authorization rules written as Puppet resources.

> Note that this module is used only for the new auth.conf file used by Puppet Server 2.2.0 and later. If you are using the auth.conf file used by core Puppet, this module will not affect it. See [Puppet Server documentation](https://docs.puppetlabs.com/puppetserver/latest/conf_file_auth.html) for detailed information about the auth.conf file.

This module allows you to add custom rules to your auth.conf file by writing Puppet resources that can create, modify, or remove the associated rules from the auth.conf file.
It allows the auth.conf to be created entirely from Puppet code---you never have to touch the auth.conf file directly.

## Setup

### Beginning with puppet_authorization

Note that this section applies only to open source Puppet. In Puppet Enterprise, this resource is managed automatically.

The `puppet_authorization` resource sets up the auth.conf and configures settings that apply globally, rather than being specific to individual rules. 


For example, this code:

~~~puppet
puppet_authorization { '/etc/puppetlabs/puppetserver/conf.d/auth.conf':
  version                => 1,
  allow_header_cert_info => false
}
~~~

...would populate the following corresponding settings into the "auth.conf" file:

~~~hocon
authorization: {
  version: 1
  allow-header-cert-info: false
  rules: ...
}
~~~

Note that the value for `rules` in this case would be set to [] if the `rules` array was not yet present in the file. Otherwise, whatever value was already in the target file for `rules` is preserved.

The values used above are:

* `version`: Currently, 1 is the only supported value and is the default.
* `allow-header-cert-info`: Controls whether the identity of the client will be inferred from the client's SSL certificate, when false, or from special X-Client HTTP headers, when true. The default for this setting is false. See Puppet Server documentation for information about [disabling HTTPS for Puppet Server](http://docs.puppetlabs.com/puppetserver/latest/external_ssl_termination.html#disable-https-for-puppet-server) and [`allow-header-cert-info` setting](https://docs.puppetlabs.com/puppetserver/latest/config_file_auth.html#allow-header-cert-info).

## Usage

The following usage examples assume an empty auth.conf file that looks like this:

~~~hocon
authorization: {
  version: 1
  rules: []
}
~~~

### Add a rule

The main resource to use is `puppet_authorization::rule`, which manages a single
rule in the authorization configuration file (auth.conf). This authorization file also
needs to be managed with a resource, which is done with `puppet_authorization`.

The following declares a resource to manage the top-level structure, followed by
a resource to add a rule for controlling access to the "environments" HTTP
endpoint:

~~~puppet
puppet_authorization::rule { 'environments':
  match_request_path   => '/puppet/v3/environments',
  match_request_type   => 'path',
  match_request_method => 'get',
  allow                => 'your.special.admin',
  sort_order           => 300,
  path                 => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
}
~~~

Here, we've declared that only `'your.special.admin'` can access the
`/puppet/v3/environments` endpoint.


### Delete a rule

Continuing from the previous example to add the "environments" rule, the
following example declares a resource that removes it from the file.

~~~puppet
puppet_authorization::rule { 'environments':
  ensure => absent,
  path   => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
}
~~~

When removing a rule, you have only to provide the rule name and path to
the configuration file where it can be found. Since rules must have unique names,
you don't have to define the other attributes (`match_request_path`, etc);
the rule with the matching name will be removed, regardless.

### Configure the catalog endpoint

You can configure the catalog HTTP endpoint for Puppet Server to: 

* Permit an administrative node to access the catalog for any node.
* Permit other nodes to be able to access their own catalog, but no other node’s catalog.

In this example, we'll configure the rule to apply only to requests made to the production or test directory environments in Puppet.

~~~puppet
puppet_authorization::rule { 'catalog_request':
  match_request_path         => '^/puppet/v3/catalog/([^/]+)$',
  match_request_type         => 'regex',
  match_request_method       => ['get','post'],
  match_request_query_params => {'environment' => [ 'production', 'test' ]},
  allow                      => ['$1', 'adminhost.mydomain.com'],
  sort_order                 => 200,
  path                       => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
}
~~~

If the original auth.conf file looked like this:

~~~hocon
authorization: {
  version: 1
  allow-header-cert-info: false
  rules: []
}
~~~

...then it should look something like this after the new rule is applied:

~~~hocon
authorization: {
  version: 1
  allow-header-cert-info: false
  rules: [
      {
          "allow" : [
              "$1",
              "adminhost.mydomain.com",
          ],
          "match-request" : {
              "method" : [
                  "get",
                  "post"
              ],
              "path" : "^/puppet/v3/catalog/([^/]+)$",
              "query-params" : {
                  "environment" : [
                      "production",
                      "test"
                  ]
              },
              "type" : "regex"
          },
          "name" : "catalog_request",
          "sort-order" : 200
      }
  ,
  ]
}
~~~

### Trigger rule changes

Puppet Server does not automatically start using the new rule definitions in the auth.conf file as they are applied. Before your auth.conf file changes take effect, the Puppet Server service needs to be restarted. Add the following code to each rule resource to restart the service any time rules in the auth.conf file changes.

If you're using open source Puppet Server, add the following code to your rule resource:

~~~puppet
notify => Service['puppetserver']
~~~

If you're using Puppet Server in PE, add:

~~~puppet
notify => Service['pe-puppetserver']
~~~

For example, with this code added, the full rule definition might look like this:

~~~puppet
puppet_authorization::rule { 'catalog_request':
  match_request_path         => '^/puppet/v3/catalog/([^/]+)$',
  match_request_type         => 'regex',
  match_request_method       => ['get','post'],
  match_request_query_params => {'environment' => [ 'production', 'test' ]},
  allow                      => ['$1', 'adminhost.mydomain.com'],
  sort_order                 => 200,
  path                       => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
  notify                     => Service['pe-puppetserver'],
}
~~~

## Reference

### Defined Types

* [`puppet_authorization`](#define-puppet_authorization)
* [`puppet_authorization::rule`](#define-puppet_authorizationrule)

### Providers

* [`puppet_authorization`](#provider-puppet_authorization)

#### Defined Type: `puppet_authorization`

Sets up the skeleton server auth.conf file if it doesn't exist.

##### Parameters (all optional)

* `version`: The `authorization.version` setting in the server auth.conf. Valid options: an integer (currently, 1 is the only supported value). Default: `1`.

* `allow_header_cert_info`: The `authorization.allow-header-cert-info` setting in the server auth.conf. Valid options: `true`, `false`. Default: `false`.

* `replace`: Whether or not to replace existing file at `path`. If set to true this will cause the file to be regenerated on every puppet run. Valid options: `true`, `false`. Default: 
`false`.

* `path`: Absolute path for auth.conf. Defaults to `name`.

#### Defined Type: `puppet_authorization::rule`

Adds individual rules to auth.conf.

##### Parameters (optional unless otherwise specified)

* `match_request_path`: Required. Valid options: a string.

* `match_request_type`: Required. Valid options: 'path', 'regex'.

* `path`: Required. The absolute path for the auth.conf file.

* `ensure`: Whether to add or remove the rule. Valid options: 'present', 'absent'. Defaults to 'present'.

* `rule_name`: The `name` setting for the rule. Valid options: a string. Defaults to `name`.

* `allow`: The `allow` setting for the rule. Cannot be set along with an `allow_unauthenticated` value of true. Valid options: a hash, a string or an array of strings and/or hashes. A hash here must contain only one of `extensions` or `certname`. Defaults to undef. For more details on the `allow` setting, see https://github.com/puppetlabs/trapperkeeper-authorization/blob/master/doc/authorization-config.md#allow.

* `deny`: The `deny` setting for the rule. Cannot be set along with an `allow_unauthenticated` value of true.  Valid options: a hash, a string or an array of strings and/or hashes. A hash here must contain only one of `extensions` or `certname`. Defaults to undef. For more details on the `deny` setting, see https://github.com/puppetlabs/trapperkeeper-authorization/blob/master/doc/authorization-config.md#deny.

* `allow_unauthenticated`: The `allow_unauthenticated` setting for the rule. Cannot be set to true along with `deny` or `allow`. Valid options: true, false. Defaults to false.

* `match_request_method`: The `method` setting for the `match_request` in the rule. Valid options: String or array of strings containing: 'put', 'post', 'get', 'head', 'delete'. Defaults to undef.

* `match_request_query_params`: The `query_params` setting for the `match_request` in the rule. Valid options: Hash. Defaults to {}.

* `sort_order`: The sort order for the rule. Valid options: an integer. Defaults to 200.

## Limitations

The auth.conf file this module writes is supported only in open source Puppet Server 2.2.0 or greater or Puppet Enterprise 2015.3.0 or greater. See (https://docs.puppetlabs.com/puppetserver/latest/config_file_auth.html) for more details about authorization in Puppet Server.

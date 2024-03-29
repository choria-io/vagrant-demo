# Reference
<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

**Functions**

* [`extlib::cache_data`](#extlibcache_data): Retrieves data from a cache file, or creates it with supplied data if the file doesn't exist
* [`extlib::default_content`](#extlibdefault_content): Takes an optional content and an optional template name and returns the contents of a file.
* [`extlib::dir_split`](#extlibdir_split): Splits the given directory or directories into individual paths.
* [`extlib::dump_args`](#extlibdump_args): Prints the args to STDOUT in Pretty JSON format.
* [`extlib::echo`](#extlibecho): This function outputs the variable content and its type to the debug log. It's similiar to the `notice` function but provides a better output
* [`extlib::file_separator`](#extlibfile_separator): Returns the os specific file path separator.
* [`extlib::has_module`](#extlibhas_module): A function that lets you know whether a specific module is on your modulepath.
* [`extlib::ip_to_cron`](#extlibip_to_cron): Provides a "random" value to cron based on the last bit of the machine IP address. used to avoid starting a certain cron job at the same time
* [`extlib::mkdir_p`](#extlibmkdir_p): Like the unix command mkdir_p except with puppet code.
* [`extlib::path_join`](#extlibpath_join): Take one or more paths and join them together using the os specific separator.
* [`extlib::random_password`](#extlibrandom_password): A function to return a string of arbitrary length that contains randomly selected characters.
* [`extlib::read_url`](#extlibread_url): Fetch a string from a URL (should only be used with 'small' remote files).  This function should only be used with trusted/internal sources. 
* [`extlib::resources_deep_merge`](#extlibresources_deep_merge): Deeply merge a "defaults" hash into a "resources" hash like the ones expected by `create_resources()`.
* [`extlib::sort_by_version`](#extlibsort_by_version): A function that sorts an array of version numbers.

**Facts**

* [`puppet_config`](#puppet_config): A fact to expose puppet settings on the agent, unlike `$settings::<setting_name>` which is resolved on the puppet master

## Functions

### extlib::cache_data

Type: Ruby 4.x API

Retrieves data from a cache file, or creates it with supplied data if the
file doesn't exist

Useful for having data that's randomly generated once on the master side
(e.g. a password), but then stays the same on subsequent runs. Because it's
stored on the master on disk, it doesn't work when you use mulitple Puppet
masters that don't share their vardir.

#### Examples

##### Calling the function

```puppet
$password = cache_data('mysql', 'mysql_password', 'this_is_my_password')
```

##### With a random password

```puppet
$password = cache_data('mysql', 'mysql_password', random_password())
```

#### `extlib::cache_data(String[1] $namespace, String[1] $name, Any $initial_data)`

Retrieves data from a cache file, or creates it with supplied data if the
file doesn't exist

Useful for having data that's randomly generated once on the master side
(e.g. a password), but then stays the same on subsequent runs. Because it's
stored on the master on disk, it doesn't work when you use mulitple Puppet
masters that don't share their vardir.

Returns: `Any` The cached value when it exists. The initial data when no cache exists

##### Examples

###### Calling the function

```puppet
$password = cache_data('mysql', 'mysql_password', 'this_is_my_password')
```

###### With a random password

```puppet
$password = cache_data('mysql', 'mysql_password', random_password())
```

##### `namespace`

Data type: `String[1]`

Namespace for the cache

##### `name`

Data type: `String[1]`

Cache key within the namespace

##### `initial_data`

Data type: `Any`

The data for when there is no cache yet

### extlib::default_content

Type: Ruby 4.x API

Takes an optional content and an optional template name and returns the contents of a file.

#### Examples

##### Using the function with a file resource.

```puppet
$config_file_content = default_content($file_content, $template_location)
file { '/tmp/x':
  ensure  => 'file',
  content => $config_file_content,
}
```

#### `extlib::default_content(Optional[String] $content, Optional[String] $template_name)`

Takes an optional content and an optional template name and returns the contents of a file.

Returns: `Optional[String]` Returns the value of the content parameter if it's a non empty string.
Otherwise returns the rendered output from `template_name`.
Returns `undef` if both `content` and `template_name` are `undef`.

##### Examples

###### Using the function with a file resource.

```puppet
$config_file_content = default_content($file_content, $template_location)
file { '/tmp/x':
  ensure  => 'file',
  content => $config_file_content,
}
```

##### `content`

Data type: `Optional[String]`



##### `template_name`

Data type: `Optional[String]`

The path to an .erb or .epp template file or `undef`.

### extlib::dir_split

Type: Puppet Language

Use this function when you need to split a absolute path into multiple absolute paths
that all descend from the given path.

#### Examples

##### calling the function

```puppet
extlib::dir_split('/opt/puppetlabs') => ['/opt', '/opt/puppetlabs']
```

#### `extlib::dir_split(Variant[Stdlib::Absolutepath, Array[Stdlib::Absolutepath]] $dirs)`

Use this function when you need to split a absolute path into multiple absolute paths
that all descend from the given path.

Returns: `Array[String]` - an array of absolute paths after being cut into individual paths.

##### Examples

###### calling the function

```puppet
extlib::dir_split('/opt/puppetlabs') => ['/opt', '/opt/puppetlabs']
```

##### `dirs`

Data type: `Variant[Stdlib::Absolutepath, Array[Stdlib::Absolutepath]]`

- either an absolute path or a array of absolute paths.

### extlib::dump_args

Type: Ruby 4.x API

Prints the args to STDOUT in Pretty JSON format.

Useful for debugging purposes only. Ideally you would use this in
conjunction with a rspec-puppet unit test.  Otherwise the output will
be shown during a puppet run when verbose/debug options are enabled.

#### `extlib::dump_args(Any $args)`

Prints the args to STDOUT in Pretty JSON format.

Useful for debugging purposes only. Ideally you would use this in
conjunction with a rspec-puppet unit test.  Otherwise the output will
be shown during a puppet run when verbose/debug options are enabled.

Returns: `Undef` Returns nothing.

##### `args`

Data type: `Any`

The data you want to dump as pretty JSON.

### extlib::echo

Type: Ruby 4.x API

This function outputs the variable content and its type to the
debug log. It's similiar to the `notice` function but provides
a better output format useful to trace variable types and values
in the manifests.

```
$v1 = 'test'
$v2 = ["1", "2", "3"]
$v3 = {"a"=>"1", "b"=>"2"}
$v4 = true
# $v5 is not defined
$v6 = { "b" => { "b" => [1,2,3], "c" => true, "d" => { 'x' => 'y' }}, 'x' => 'y', 'z' => [1,2,3,4,5,6]}
$v7 = 12345

echo($v1, 'My string')
echo($v2, 'My array')
echo($v3, 'My hash')
echo($v4, 'My boolean')
echo($v5, 'My undef')
echo($v6, 'My structure')
echo($v7) # no comment here
debug log output
My string (String) "test"
My array (Array) ["1", "2", "3"]
My hash (Hash) {"a"=>"1", "b"=>"2"}
My boolean (TrueClass) true
My undef (String) ""
My structure (Hash) {"b"=>{"b"=>["1", "2", "3"], "c"=>true, "d"=>{"x"=>"y"}}, "x"=>"y", "z"=>["1", "2", "3", "4", "5", "6"]}
(String) "12345"
```

#### `extlib::echo(Any $value, Optional[String] $comment)`

This function outputs the variable content and its type to the
debug log. It's similiar to the `notice` function but provides
a better output format useful to trace variable types and values
in the manifests.

```
$v1 = 'test'
$v2 = ["1", "2", "3"]
$v3 = {"a"=>"1", "b"=>"2"}
$v4 = true
# $v5 is not defined
$v6 = { "b" => { "b" => [1,2,3], "c" => true, "d" => { 'x' => 'y' }}, 'x' => 'y', 'z' => [1,2,3,4,5,6]}
$v7 = 12345

echo($v1, 'My string')
echo($v2, 'My array')
echo($v3, 'My hash')
echo($v4, 'My boolean')
echo($v5, 'My undef')
echo($v6, 'My structure')
echo($v7) # no comment here
debug log output
My string (String) "test"
My array (Array) ["1", "2", "3"]
My hash (Hash) {"a"=>"1", "b"=>"2"}
My boolean (TrueClass) true
My undef (String) ""
My structure (Hash) {"b"=>{"b"=>["1", "2", "3"], "c"=>true, "d"=>{"x"=>"y"}}, "x"=>"y", "z"=>["1", "2", "3", "4", "5", "6"]}
(String) "12345"
```

Returns: `Undef` Returns nothing.

##### `value`

Data type: `Any`

The value you want to inspect.

##### `comment`

Data type: `Optional[String]`

An optional comment to prepend to the debug output.

### extlib::file_separator

Type: Puppet Language

Returns the os specific file path separator.

#### Examples

##### Example of how to use

```puppet
extlib::file_separator() => '/'
```

#### `extlib::file_separator()`

The extlib::file_separator function.

Returns: `String` - The os specific path separator.

##### Examples

###### Example of how to use

```puppet
extlib::file_separator() => '/'
```

### extlib::has_module

Type: Ruby 4.x API

A function that lets you know whether a specific module is on your modulepath.

#### Examples

##### Calling the function

```puppet
extlib::has_module('camptocamp/systemd')
```

#### `extlib::has_module(Pattern[/\A\w+[-\/]\w+\z/] $module_name)`

A function that lets you know whether a specific module is on your modulepath.

Returns: `Boolean` Returns `true` or `false`.

##### Examples

###### Calling the function

```puppet
extlib::has_module('camptocamp/systemd')
```

##### `module_name`

Data type: `Pattern[/\A\w+[-\/]\w+\z/]`

The full name of the module you want to know exists or not.
Namespace and modulename can be separated with either `-` or `/`.

### extlib::ip_to_cron

Type: Ruby 4.x API

Provides a "random" value to cron based on the last bit of the machine IP address.
used to avoid starting a certain cron job at the same time on all servers.
Takes the runinterval in seconds as parameter and returns an array of [hour, minute]

example usage
```
ip_to_cron(3600) - returns [ '*', one value between 0..59 ]
ip_to_cron(1800) - returns [ '*', an array of two values between 0..59 ]
ip_to_cron(7200) - returns [ an array of twelve values between 0..23, one value between 0..59 ]
```

#### `extlib::ip_to_cron(Optional[Integer[1]] $runinterval)`

Provides a "random" value to cron based on the last bit of the machine IP address.
used to avoid starting a certain cron job at the same time on all servers.
Takes the runinterval in seconds as parameter and returns an array of [hour, minute]

example usage
```
ip_to_cron(3600) - returns [ '*', one value between 0..59 ]
ip_to_cron(1800) - returns [ '*', an array of two values between 0..59 ]
ip_to_cron(7200) - returns [ an array of twelve values between 0..23, one value between 0..59 ]
```

Returns: `Array`

##### `runinterval`

Data type: `Optional[Integer[1]]`

The number of seconds to use as the run interval

### extlib::mkdir_p

Type: Puppet Language

This creates file resources for all directories and utilizes the dir_split() function
to get a list of all the descendant directories.  You will have no control over any other parameters
for the file resource.  If you wish to control the file resources you can use the dir_split() function
and get an array of directories for use in your own code.  Please note this does not use an exec resource.

* **Note** splits the given directories into paths that are then created using file resources

#### Examples

##### How to use

```puppet
extlib::mkdir_p('/opt/puppetlabs/bin') => ['/opt', '/opt/puppetlabs', '/opt/puppetlabs/bin']
```

#### `extlib::mkdir_p(Variant[Stdlib::Absolutepath, Array[Stdlib::Absolutepath]] $dirs)`

This creates file resources for all directories and utilizes the dir_split() function
to get a list of all the descendant directories.  You will have no control over any other parameters
for the file resource.  If you wish to control the file resources you can use the dir_split() function
and get an array of directories for use in your own code.  Please note this does not use an exec resource.

Returns: `Array[Stdlib::Absolutepath]`

##### Examples

###### How to use

```puppet
extlib::mkdir_p('/opt/puppetlabs/bin') => ['/opt', '/opt/puppetlabs', '/opt/puppetlabs/bin']
```

##### `dirs`

Data type: `Variant[Stdlib::Absolutepath, Array[Stdlib::Absolutepath]]`

- the path(s) to create

### extlib::path_join

Type: Puppet Language

Because in how windows uses a different separator this function
will format a windows path into a equilivent unix like path.  This type of unix like
path will work on windows.

#### Examples

##### Joining Unix paths to return `/tmp/test/libs`

```puppet
extlib::path_join('/tmp', 'test', 'libs')
```

##### Joining Windows paths to return `/c/test/libs`

```puppet
extlib::path_join('c:', 'test', 'libs')
```

#### `extlib::path_join(Array[String] $dirs)`

Because in how windows uses a different separator this function
will format a windows path into a equilivent unix like path.  This type of unix like
path will work on windows.

Returns: `Stdlib::Absolutepath` The joined path

##### Examples

###### Joining Unix paths to return `/tmp/test/libs`

```puppet
extlib::path_join('/tmp', 'test', 'libs')
```

###### Joining Windows paths to return `/c/test/libs`

```puppet
extlib::path_join('c:', 'test', 'libs')
```

##### `dirs`

Data type: `Array[String]`

Joins two or more directories by file separator.

### extlib::random_password

Type: Ruby 4.x API

A function to return a string of arbitrary length that contains randomly selected characters.

#### Examples

##### Calling the function

```puppet
random_password(42)
```

#### `extlib::random_password(Integer[1] $length)`

A function to return a string of arbitrary length that contains randomly selected characters.

Returns: `String` The random string returned consists of alphanumeric characters excluding 'look-alike' characters.

##### Examples

###### Calling the function

```puppet
random_password(42)
```

##### `length`

Data type: `Integer[1]`

The length of random password you want generated.

### extlib::read_url

Type: Ruby 4.x API

Fetch a string from a URL (should only be used with 'small' remote files).

This function should only be used with trusted/internal sources.
This is especially important if using it in conjunction with `inline_template`
or `inline_epp`.
The current implementation is also very basic.  No thought has gone into timeouts,
support for redirects, CA paths etc.

#### Examples

##### Calling the function

```puppet
extlib::read_url('https://example.com/sometemplate.epp')
```

#### `extlib::read_url(Stdlib::HTTPUrl $url)`

Fetch a string from a URL (should only be used with 'small' remote files).

This function should only be used with trusted/internal sources.
This is especially important if using it in conjunction with `inline_template`
or `inline_epp`.
The current implementation is also very basic.  No thought has gone into timeouts,
support for redirects, CA paths etc.

Returns: `String` Returns the contents of the url as a string

##### Examples

###### Calling the function

```puppet
extlib::read_url('https://example.com/sometemplate.epp')
```

##### `url`

Data type: `Stdlib::HTTPUrl`

The URL to read from

### extlib::resources_deep_merge

Type: Ruby 4.x API

Deeply merge a "defaults" hash into a "resources" hash like the ones expected by `create_resources()`.

Internally calls the puppetlabs-stdlib function `deep_merge()`. In case of
duplicate keys the `resources` hash keys win over the `defaults` hash keys.

Example
```puppet
$defaults_hash = {
  'one'   => '1',
  'two'   => '2',
  'three' => '3',
  'four'  => {
    'five'  => '5',
    'six'   => '6',
    'seven' => '7',
  }
}

$numbers_hash = {
  'german' => {
    'one'   => 'eins',
    'three' => 'drei',
    'four'  => {
      'six' => 'sechs',
    },
  },
  'french' => {
    'one' => 'un',
    'two' => 'deux',
    'four' => {
      'five'  => 'cinq',
      'seven' => 'sept',
    },
  }
}

$result_hash = resources_deep_merge($numbers_hash, $defaults_hash)
```

The $result_hash then looks like this:

```puppet
$result_hash = {
  'german' => {
    'one'   => 'eins',
    'two'   => '2',
    'three' => 'drei',
    'four'  => {
      'five'  => '5',
      'six'   => 'sechs',
      'seven' => '7',
    }
  },
  'french' => {
    'one'   => 'un',
    'two'   => 'deux',
    'three' => '3',
    'four'  => {
      'five'  => 'cinq',
      'six'   => '6',
      'seven' => 'sept',
    }
  }
}
```

#### `extlib::resources_deep_merge(Hash $resources, Hash $defaults)`

Deeply merge a "defaults" hash into a "resources" hash like the ones expected by `create_resources()`.

Internally calls the puppetlabs-stdlib function `deep_merge()`. In case of
duplicate keys the `resources` hash keys win over the `defaults` hash keys.

Example
```puppet
$defaults_hash = {
  'one'   => '1',
  'two'   => '2',
  'three' => '3',
  'four'  => {
    'five'  => '5',
    'six'   => '6',
    'seven' => '7',
  }
}

$numbers_hash = {
  'german' => {
    'one'   => 'eins',
    'three' => 'drei',
    'four'  => {
      'six' => 'sechs',
    },
  },
  'french' => {
    'one' => 'un',
    'two' => 'deux',
    'four' => {
      'five'  => 'cinq',
      'seven' => 'sept',
    },
  }
}

$result_hash = resources_deep_merge($numbers_hash, $defaults_hash)
```

The $result_hash then looks like this:

```puppet
$result_hash = {
  'german' => {
    'one'   => 'eins',
    'two'   => '2',
    'three' => 'drei',
    'four'  => {
      'five'  => '5',
      'six'   => 'sechs',
      'seven' => '7',
    }
  },
  'french' => {
    'one'   => 'un',
    'two'   => 'deux',
    'three' => '3',
    'four'  => {
      'five'  => 'cinq',
      'six'   => '6',
      'seven' => 'sept',
    }
  }
}
```

Returns: `Hash` Returns the merged hash.

##### `resources`

Data type: `Hash`

The hash of resources.

##### `defaults`

Data type: `Hash`

The hash of defaults to merge.

### extlib::sort_by_version

Type: Ruby 4.x API

A function that sorts an array of version numbers.

## Facts

### puppet\_config

This facts exposes some facts from both the main and master section of the puppet agent configueration.  The following facts are supported

```
{
  main => {
    hostpubkey,
    hostprivkey,
    hostcert,
    localcacert,
    ssldir,
    vardir,
    server,
  },
  master => {
    localcacert,
    ssldir,
  }
}
```

#### Examples

##### Calling the function

```puppet
extlib::sort_by_version(['10.0.0b12', '10.0.0b3', '10.0.0a2', '9.0.10', '9.0.3'])
```

#### `extlib::sort_by_version(Array[String] $versions)`

A function that sorts an array of version numbers.

Returns: `Array[String]` Returns the sorted array.

##### Examples

###### Calling the function

```puppet
extlib::sort_by_version(['10.0.0b12', '10.0.0b3', '10.0.0a2', '9.0.10', '9.0.3'])
```

##### `versions`

Data type: `Array[String]`

An array of version strings you want sorted.


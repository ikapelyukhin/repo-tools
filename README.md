# Repo tools

## Installation

### From RPM package

1. Get the package from [home:ikapelyukhin/repo-tools](https://build.opensuse.org/package/show/home:ikapelyukhin/repo-tools)
2. Install it
3. Run the scripts! (They are installed into `/usr/share/repo-tools`)

### From source

1. `git clone`
2. `bundle install`
3. Run the scripts!

#### verify_repo

`verify_repo.rb` verifies that all packages in the repository have a correct size. For all those
times when somebody uploads broken repos to the CDN (╯°□°）╯︵ ┻━┻

It does so by issuing `HEAD` requests and comparing `Content-Length` response header with the size
specified in the metadata file. The requests are issued in parallel, so this is the quick way to check
if the repo contains any malformed files.

The only other way to verify the integrity of the repo would be to download every package and
calculate checksums.

```
Usage: verify_repo.rb REPO_URL
Authentication token can be supplied as query string, e.g.: https://repo.url/?auth_token
```

#### repo_stats

`repo_stats.rb` shows repository statistics based on the metadata. For all those times when you
need to know how much space the repository will take before mirroring it.

```
Usage: repo_stats.rb REPO_URL
Authentication token can be supplied as query string, e.g.: https://repo.url/?auth_token
```

```
Statistics for http://download.opensuse.org/update/leap/15.0/oss/

     src:    636 RPM packages,      0 deltainfo packages,  12.49 gigabytes
  x86_64:   2807 RPM packages,   1072 deltainfo packages,   7.85 gigabytes
  noarch:    805 RPM packages,    468 deltainfo packages,   3.38 gigabytes

Total size:  23.73 gigabytes
```

#### dump_filenames

`dump_filenames.rb` prints filenames of all packages in the repo. Handy for comparing repo contents.

```
Usage: dump_filenames.rb REPO_URL
Authentication token can be supplied as query string, e.g.: https://repo.url/?auth_token
```

#### outdated_packages

`outdated_packages.rb` calculates disk usage by outdated packages in the mirrored repos (old versions of the packages that are retained on disk after newer versions are downloaded and aren't referenced by the metadata).

```
Usage: outdated_packages.rb MIRROR_DIR
```


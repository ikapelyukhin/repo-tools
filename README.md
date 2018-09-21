# Repo tools

## Installation

1. `git clone`
2. `bundle install`
3. Run scripts!

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
Statistics for https://download.opensuse.org/update/leap/42.3/oss/

     src:   1678 packages,  42.24 gigabytes
  x86_64:   7774 packages,  17.24 gigabytes
  noarch:   2243 packages,   7.11 gigabytes

Total size:  66.60 gigabytes
```

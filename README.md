# Repo tools

## Installation

1. `git clone`
2. `bundle install`
3. Run scripts!

#### repo_stats

```
Usage: repo_stats.rb REPO_URL
Authentication token can be supplied as query string, e.g.: https://repo.url/?auth_token
```

`repo_stats.rb` shows repository statistics based on the metadata. For all those cases when you
need to know how much space the repository will take before mirroring it.

```
Statistics for https://download.opensuse.org/update/leap/42.3/oss/

     src:   1678 packages,  42.24 gigabytes
  x86_64:   7774 packages,  17.24 gigabytes
  noarch:   2243 packages,   7.11 gigabytes

Total size:  66.60 gigabytes
```

#### verify_repo

```
Usage: verify_repo.rb REPO_URL
Authentication token can be supplied as query string, e.g.: https://repo.url/?auth_token
```

`verify_repo.rb` verifies that all packages in the repository have a correct size. It does so by
issuing `HEAD` requests and comparing `Content-Length` response header with the size specified in
the metadata file. The requests are issued in paralel, so this is the quick way to check if the
repo contains any malformed files.

The only other way to verify the integrity of the repo would be to download every package and
calculate checksums.

**Caveats:**

* Doesn't verify delta-RPM packages (yet)
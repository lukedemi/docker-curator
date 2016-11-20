## Overview

I had enough difficulty trying to run cron and Curator 4.X together in a Docker container that I decided to release something for people to either run themselves or use as a jumping off point for their own implementation.

The main limitation of this container is that you can only perform one action per index and only close, delete, snapshot, and forcemerge are supported. I do think this container should work fine for most simple ELK configurations with just the default values.

## Usage Quick Start

Below is the minimal configuration necessary to run delete, close, snapshot, and forcemerge on localhost:9200 once a day on logstash prefixed indices. See Parameters below for all available options to fine tune the different actions

```
docker run -d \
  -e CLOSE_HOUR=8 \
  -e DELETE_HOUR=7 \
  -e SNAPSHOT_HOUR=9 \
  -e SNAPSHOT_REPOSITORY=curator-s3 \
  -e FORCEMERGE_HOUR=10 \
  lukedemi/curator
```

A way to use this container on multiple indices is to just run two. Just be careful to avoid forcemerging two potentially large indices at the same time. Here's a configuration example that closely matches a past production environment.

```
docker run -d \
  --name logstash
  -e INDEX_PREFIX=logstash \
  -e CLOSE_DAY=30 \
  -e CLOSE_HOUR=8 \
  -e DELETE_DAY=31 \
  -e DELETE_HOUR=7 \
  -e SNAPSHOT_HOUR=9 \
  -e SNAPSHOT_REPOSITORY=curator-s3 \
  -e FORCEMERGE_HOUR=10 \
  -e FORCEMERGE_TIMEOUT=10800 \
  lukedemi/curator

docker run -d \
  --name kinesis \
  -e INDEX_PREFIX=kinesis \
  -e CLOSE_DAY=7 \
  -e CLOSE_HOUR=8 \
  -e DELETE_DAY=8 \
  -e DELETE_HOUR=7 \
  -e SNAPSHOT_HOUR=9 \
  -e SNAPSHOT_REPOSITORY=curator-s3 \
  lukedemi/curator
```

## Parameters

Curator configuration is set using environment variables when running the container (`docker run -e VAR=value`). See below for those parameters and their default values.

### Global Configuration

- `ELASTICSEARCH_HOST=localhost`
- `ELASTICSEARCH_PORT=9200`
- `MASTER_ONLY=False`
- `SSL=False`
- `INDEX_PREFIX=logstash`
- `TIME_STRING=%Y.%m.%d`

### Close

- `CLOSE_HOUR=...`
 
  No default value - setting CLOSE_HOUR enables daily curator closing using the default settings at the specified hour.

- `CLOSE_MINUTE=0`
- `CLOSE_DAY=7`
 
  Indices with a name older than this integer will beclosed based on TIME_STRING pattern.

### Delete

- `DELETE_HOUR=...`
 
  No default value - setting DELETE_HOUR enables daily curator deletion using the default settings at the specified hour.

- `DELETE_MINUTE=0`
- `DELETE_DAY=7`
 
  Indices with a name older than this integer will be deleted based on TIME_STRING pattern.

### Snapshot

- `SNAPSHOT_HOUR=...` (Required)
 
  No default value - setting SNAPSHOT_HOUR and SNAPSHOT_REPOSITORY enables daily curator snapshots using the default settings at the specified hour.

- `SNAPSHOT_MINUTE=0`
- `SNAPSHOT_REPOSITORY=...` (Required)
 
  No default value - Elasticsearch repository to save snapshots. See Elasticsearch documentation for instructions on [how to create a repository](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html#_repositories). 
- `SNAPSHOT_FROM_DAY=2`
 
  Curator will snapshot indices with a name older than this integer based on TIME_STRING pattern.
- `SNAPSHOT_TO_DAY=7`
 
  Curator will snapshot indices with a name younger than this integer based on TIME_STRING pattern.
- `SNAPSHOT_TIMEOUT=3600`

### Force Merge

- `FORCEMERGE_HOUR=...`
 
  No default value - setting FORCEMERGE_HOUR enables daily force merges using the default settings at the specified hour.

- `FORCEMERGE_MINUTE=0`
- `FORCEMERGE_SEGMENTS=2`
- `FORCEMERGE_DELAY=120`
- `FORCEMERGE_FROM_DAY=2`
 
  Indices with a name older than this integer will be force merged.
- `FORCEMERGE_TO_DAY=7`
 
  Indices with a name older than this integer will be force merged.
- `FORCEMERGE_TIMEOUT=3600`

## Overview

Run Curator on a schedule in a Docker container. 

I had enough difficulty trying to run cron and curator 4.0 together in a docker container that I decided it made sense to release something general for those who might be put in a similar situation.

Basic limitations are that you can only perform actions on one index and only perform one of each of the below actions on that index. I do think this container should work fine for most simple ELK configurations with just the default values.

## Usage Quick Start

Below is the minimal configuration necessary to run delete, close, snapshot, and forcemerge on localhost:9200 once a day on logastash prefixed indices. See Parameters below for all available options to fine tune the instance.

```
docker run -d \
  -e DELETE_HOUR=7 \
  -e CLOSE_HOUR=8 \
  -e SNAPSHOT_HOUR=9 \
  -e FORCEMERGE_HOUR=10 \
  curator
```

## Parameters

Parameters of Curator configuration are set using environment variables
when running the container (`docker run -e VAR=value`). See below for those parameters and their default values.

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
- `TIMEOUT=3600`

### Snapshot

- `FORCEMERGE_HOUR=...`
 
  No default value - setting FORCEMERGE_HOUR enables daily force merges using the default settings at the specified hour.

- `FORCEMERGE_MINUTE=0`
- `FORCEMERGE_SEGMENTS=2`
- `FORCEMERGE_DELAY=120`
- `FORCEMERGE_FROM_DAY=2`
 
  Indices with a name older than this integer will be force merged.
- `FORCEMERGE_TO_DAY=7`
 
  Indices with a name older than this integer will be force merged.
- `TIMEOUT=3600`

#!/bin/bash

sed -i 's/{{INDEX_PREFIX}}/'"${INDEX_PREFIX:-logstash}"'/g' /templates/*
sed -i 's/{{TIME_STRING}}/'"${TIME_STRING:-%Y.%m.%d}"'/g' /templates/*

if [ -n "$CLOSE_HOUR" ]; then
  cat /templates/cron |
  sed 's/{{ACTION}}/close/g' |
  sed 's/{{HOUR}}/'"${CLOSE_HOUR:-8}"'/g' |
  sed 's/{{MINUTE}}/'"${CLOSE_MINUTE:-0}"'/g' |
  cat >> /etc/crontab

  cat /templates/close.yml |
  sed 's/{{CLOSE_DAY}}/'"${CLOSE_DAY:-7}"'/g' |
  cat >> /actions/close.yml
fi

if [ -n "$DELETE_HOUR" ]; then
  cat /templates/cron |
  sed 's/{{ACTION}}/delete/g' |
  sed 's/{{HOUR}}/'"${DELETE_HOUR:-9}"'/g' |
  sed 's/{{MINUTE}}/'"${DELETE_MINUTE:-0}"'/g' |
  cat >> /etc/crontab

  cat /templates/delete.yml |
  sed 's/{{DELETE_DAY}}/'"${DELETE_DAY:-8}"'/g' |
  cat > /actions/delete.yml
fi

if [ -n "$SNAPSHOT_HOUR" ] && [ -n "$SNAPSHOT_REPOSITORY" ]; then
  cat /templates/cron |
  sed 's/{{ACTION}}/snapshot/g' |
  sed 's/{{HOUR}}/'"${SNAPSHOT_HOUR:-10}"'/g' |
  sed 's/{{MINUTE}}/'"${SNAPSHOT_MINUTE:-0}"'/g' |
  cat >> /etc/crontab

  cat /templates/snapshot.yml |
  sed 's/{{SNAPSHOT_FROM_DAY}}/'"${SNAPSHOT_FROM_DAY:-2}"'/g' |
  sed 's/{{SNAPSHOT_REPOSITORY}}/'"${SNAPSHOT_REPOSITORY}"'/g' |
  sed 's/{{SNAPSHOT_TIMEOUT}}/'"${SNAPSHOT_TIMEOUT:-3600}"'/g' |
  sed 's/{{SNAPSHOT_TO_DAY}}/'"${SNAPSHOT_TO_DAY:-7}"'/g' |
  cat > /actions/snapshot.yml
fi

if [ -n "$FORCEMERGE_HOUR" ]; then
  cat /templates/cron |
  sed 's/{{ACTION}}/forcemerge/g' |
  sed 's/{{HOUR}}/'"${FORCEMERGE_HOUR:-11}"'/g' |
  sed 's/{{MINUTE}}/'"${FORCEMERGE_MINUTE:-0}"'/g' |
  cat >> /etc/crontab

  cat /templates/forcemerge.yml |
  sed 's/{{FORCEMERGE_DELAY}}/'"${FORCEMERGE_DELAY:-120}"'/g' |
  sed 's/{{FORCEMERGE_FROM_DAY}}/'"${FORCEMERGE_FROM_DAY:-3}"'/g' |
  sed 's/{{FORCEMERGE_SEGMENTS}}/'"${FORCEMERGE_SEGMENTS:-2}"'/g' |
  sed 's/{{FORCEMERGE_TIMEOUT}}/'"${FORCEMERGE_TIMEOUT:-3600}"'/g' |
  sed 's/{{FORCEMERGE_TO_DAY}}/'"${FORCEMERGE_TO_DAY:-5}"'/g' |
  cat > /actions/forcemerge.yml
fi

cat /templates/config.yml |
sed 's/{{ELASTICSEARCH_HOST}}/'"${ELASTICSEARCH_HOST:-localhost}"'/g' |
sed 's/{{ELASTICSEARCH_PORT}}/'"${ELASTICSEARCH_PORT:-9200}"'/g' |
sed 's/{{MASTER_ONLY}}/'"${MASTER_ONLY:-False}"'/g' |
sed 's/{{SSL}}/'"${SSL:-False}"'/g' |
cat > /config/config.yml

touch /var/log/cron.log

cron

tail -qf /var/log/cron.log

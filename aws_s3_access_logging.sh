#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-01-21 18:13:28 +0000 (Tue, 21 Jan 2020)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

# Lists S3 buckets and their access logging status
#
# Output Format:
#
# S3_Bucket      TargetPrefix    TargetBucket
#
# If access logging isn't configured on a bucket, outputs:
#
# S3_Bucket      S3_ACCESS_LOGGING_NOT_CONFIGURED

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x

buckets="$(aws s3 ls | cut -d' ' -f3-)"

num_buckets="$(wc -l <<< "$buckets")"
num_buckets="${num_buckets//[[:space:]]}"

echo "Fetching access logging status for each of $num_buckets buckets (this may take a while):" >&2
while read -r name; do
    printf '%s\t' "$name"
    output="$(aws s3api get-bucket-logging --bucket "$name" |
    jq -r '.LoggingEnabled | [.TargetPrefix, .TargetBucket] | @tsv')"
    if [ -z "$output" ]; then
        echo "S3_ACCESS_LOGGING_NOT_CONFIGURED"
    else
        echo "$output"
    fi
done <<< "$buckets" #|
#sort |
#column -t

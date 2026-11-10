# Narrative: recruiter (30 seconds, skimmed)

Draft built from `impact-log.md`. Rewrite in your own words before using it.

## The pitch
> FinComm is a production-style AWS project I built end to end: the network and identity layers as Terraform, a multi-language microservices app from the OpenTelemetry demo run in Docker, and Kubernetes on EKS next. I document decisions and incidents as I go.

## Three facts to lead with
- Network layer defined as code: 9 Terraform resources, remote state in S3.
- Containerised a Go service that serves real data from Postgres, verified with a script.
- Cut a repeat Docker build from 102.6 s to 3.76 s by ordering layers for the cache (measured).

## Keywords this honestly supports
Terraform, AWS (VPC, IAM, EC2, S3), Docker, gRPC, PostgreSQL, Git, IaC, incident write-ups.

## Don't say yet
Kubernetes, EKS, CI/CD, observability. They aren't built. Use "next" or "in progress".

## Your words (fill in)
- One sentence on why you built it this way: ______

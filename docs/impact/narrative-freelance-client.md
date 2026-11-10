# Narrative: freelance client (small team, cares about cost, speed, risk)

Draft built from `impact-log.md`. A client will ask what this means for them. Answer with what you've demonstrated, not with promises.

## The pitch
> I set up the cloud foundation so your developers don't have to think about it: network, access control and containers, written as code so it can be rebuilt the same way every time.

## What I've demonstrated (measured)
- Infrastructure as code: network layer rebuildable from a repo, state stored remotely.
- Faster deploy builds: a repeat container build takes 3.76 s instead of 102.6 s when the Dockerfile is ordered for caching.
- Safer access: IAM kept separate, permissions written as least-privilege, risks documented.
- Written incident and decision records, so the team can follow my reasoning later.

## What that could mean for you (projection, assumptions stated)
If your team runs 50 builds a day and each saves 75 seconds, that's about an hour of waiting removed per day. This depends on a warm build cache, so treat it as an estimate.

## What I haven't done yet (say it up front)
No production client work, no cost tracking, no monitoring, Kubernetes still in progress. Offer a small paid first task rather than a big promise, for example containerising one service and documenting the build.

## Your words (fill in)
- The first small job you'd offer: ______

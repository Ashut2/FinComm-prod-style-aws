# Narrative: hiring manager (interview, 2 to 3 minutes, expects depth)

Draft built from `impact-log.md`. Rewrite in your own words. Be ready to be asked "how do you know?" for every number.

## The story
1. **Problem I set:** run a real microservices app the way a team would: reproducible infra, least-privilege access, containers, and later Kubernetes.
2. **Decisions with reasons**
   - IAM lives in its own Terraform root with its own state, so destroying the app can never delete the role Terraform runs as.
   - NAT Gateway decided ahead of need, recorded in an ADR (`docs/adr/`).
   - Dockerfile ordered so dependencies are cached: a repeat build took 3.76 s vs 102.6 s cold, a one-line code edit 28 s (measured).
3. **Something that went wrong and what I learned:** incident #001. Two sequential root causes (rotated ISP IP, then a variable declared but never wired). The first error hid the second. About 5 hours to find, my estimate.
4. **How I verify:** I test the data path, not just the port. A script proved the container returns 10 real products from Postgres.

## Likely follow-up questions (practise out loud)
- Why separate Terraform roots? What breaks if they're combined?
- Why does instruction order change Docker build time?
- Your deployer policy uses `Resource: "*"` on EC2 actions. What would you tighten and how?
- What's still missing before this is production-ready?

## Honest limits to volunteer
Single instance, no HA, no monitoring yet, deployer policy not yet attached or tested, app runs locally and in Docker but is not yet deployed to AWS.

## Your words (fill in)
- What you'd do differently: ______

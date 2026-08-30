# ADR-000: NAT Gateway — Do We Need One for FinCommerce Right Now?

**Date:** 30 August 2026
**Status:** <Proposed / Decided> -> Proposed

## Context

There is no application deployed yet, and the eventual application
architecture (3-tier vs. microservices) has not been decided -> this
ADR does not depend on that decision.

What is already known from the project roadmap:
- Week 7 provisions an EKS cluster (Kubernetes), whose worker nodes
  will very likely sit in a private subnet, per standard AWS/EKS
  practice -> not because a specific app design demands it, but because
  this is the conventional pattern regardless of app shape.
- Private-subnet compute needs outbound internet access (pulling
  container images, package updates, reaching AWS APIs) without being
  directly reachable from the internet inbound -> this is the specific
  problem NAT solves.
- No private subnet exists yet in the current Terraform config
  (`terraform/vpc_foundations/` only has a public tier so far).

This ADR is a forward-looking infrastructure decision, made ahead of
the private subnet's creation, not a reaction to an existing built
requirement.

## Options Considered

**Option 1: No NAT Gateway — public subnet only, for now**
- What does this cost? (in $ and in realism)

Financial Cost: $0.00 per month. It is completely free because we are using standard Internet Gateways and public subnets.

Realistic Cost: Every resource (databases, backend servers) must have a public IPv4 address, which now costs ~$3.65/month per IP on AWS, plus a high structural security risk.

- What do you lose the ability to do?

What you lose the ability to do: You lose the ability to isolate your architecture. Your database and servers are exposed to the public internet. If a firewall or Security Group rule is misconfigured, your entire backend is vulnerable to direct external attacks.



**Option 2: Single NAT Gateway (one AZ)**
- What does this cost?

Financial Cost: In the ap-south-1 (Mumbai) region, the fixed rate is $0.056 per hour. This equals roughly $40.99 per month as a flat baseline fee, even if zero traffic passes through it. On top of this, we are charged a data processing fee of $0.056 per GB and standard data transfer fees.

Realistic Cost: Expensive for a personal project. It will quietly consume our budget if our application downloads large container images or packages.

- What single point of failure does this introduce?

It introduces an Availability Zone (AZ) dependency. If the specific AZ hosting our single NAT Gateway goes down, resources in all other AZs lose their outbound internet connection instantly.

**Option 3: NAT Gateway per AZ (production-standard HA pattern)**
- What does this cost, doubled?

financial cost: It would doubled or tripled the cost (40$ * 2x or 3x ). For a 2 AZ's setup baseline cost jumps to 80.91$/month plus a data processing fee of 0.056$ / GB at each gateway 

Realistic Cost: Prohibitive and financially draining for a non-commercial side project

- Is this actually justified for a portfolio project that isn't serving
  real traffic?

It is not justified for the portfolio project like this where there are no real users and capital flow involved. While it is the industry standard for High Availability (HA) to prevent cross-AZ data transfer fees and mitigate blast radiuses in business settings, a portfolio project does not require enterprise-grade uptime 

**Option 4: NAT Instance instead of NAT Gateway (self-managed EC2 alternative)**
- Cheaper, but what do you now have to manage yourself that AWS would
  otherwise handle?

financial cost: 3.00 to $6.00 per month. we only pay the standard hourly rate for a tiny EC2 instance (like a t4g.nano or t3.micro), with $0.00 data processing fees.

realistic cost: Highly realistic and cost-efficient for learning networks without breaking the bank.

Tradeoff -> I have to manage underlying Infrastructure problem that AWS was handling in traditional NAT gateways. Things like OS security patching, Software updates, bandwidth scaling automatic failover if instance crashes or run out of memory. 

## Decision

I'm going with NAT Instance to get a demonstration video of this project to imitate  the real production-style scenario with minimized cost.

## Why This Option

- What made this the right call *for this specific project, at this specific
  stage* — not "what's best practice in general," but what's right for a
  portfolio project on a tight budget with no real users yet?

  I don't have a budget of 80$ to have my Nat gateway sitting idle for a month or two.
  Mainly because of cost leaving NAT gateway option but NAT instance cost really less with a baseline 3$ and 0$ data processing fee.

  NAT Instance makes more sense for current scope of the project. 

## Trade-offs / What You Gave Up
- Downside
No Nat gateway would have been disaster as it would prevent us from building a isolative architecture. Nat Instance enable us to do that. 
But I have to manually go through when breakdown like memory run out & OS patching & bandwidth scaling happens.



## How You'd Revisit This at Larger Scale
- If FinCommerce were real, serving real users — would this decision change?
  Why?

If FinCommerce were real, serving real users then I would've gone probably with `NAT gateway per AZ` option. That would have cost more but the need of 24*7 uptime at any circumstances would've been taken care of. which is greater payoff down the development line. 
plus things like OS patching, instance memory ran out, bandwidth scaling et cetera would've been taken care of from AWS Side, requiring almost no intervention from our side. 

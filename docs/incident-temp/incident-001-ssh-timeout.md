# Incident #001 — SSH Connection Failure to app_server

**Date:** September 2, 2026
**Severity:** Low (dev environment, no user impact)

## Impact
No production impact — this was first-time SSH setup to a newly-provisioned
instance in the custom VPC. Blocked completion of Day 12's connectivity test.

## Detection
Manual — attempted SSH to verify Security Group rules after provisioning,
connection failed with "Connection timed out."

## Timeline
1. Initial SSH attempt → connection timed out
2. Verified SG, route table, IGW, NACLs, subnet placement — all individually
   correct via AWS CLI
3. Ruled out local network/firewall via `ssh -T git@github.com` (succeeded,
   proving outbound port 22 worked from this machine)
4. Discovered local public IP had changed multiple times during the session
   (dynamic ISP-assigned IP), no longer matching the SG's allowed CIDR
5. Updated SG to current IP, reapplied — SSH progressed further: TCP
   handshake now succeeded, but failed at authentication
   ("Permission denied (publickey)")
6. Verified local `.pem` file's public key matched AWS's registered key for
   `fincomm-app-key` exactly — ruled out wrong/corrupted key file
7. Checked instance state directly (`terraform state show`) — found
   `key_name = null`
8. Found root cause: `key_name` variable was declared in the module but
   never referenced inside the `aws_instance` resource block, and never
   passed a value from the root module's call — instance had no key
   attached since creation
9. Added `key_name = var.key_name` to the module resource and
   `key_name = "fincomm-app-key"` to the root module call, forced
   replacement, reapplied
10. SSH succeeded

## Symptoms
- First symptom: full connection timeout (no TCP handshake)
- Second symptom, after fixing the first: TCP handshake succeeded, but
  key-based auth was rejected

## Hypotheses (in order tried)
1. Security Group misconfiguration — ruled out, rules were correct
2. Route table / IGW / NACL misconfiguration — ruled out, all correct
3. Local network/firewall blocking outbound SSH — ruled out via GitHub test
4. Stale local public IP vs. SG's allowed CIDR — **confirmed**, this was
   the first real cause
5. Wrong or mismatched SSH key file — ruled out, keys matched exactly
6. Key never attached to the instance at all — **confirmed**, this was
   the second real cause

## Evidence
- `aws ec2 describe-security-groups` confirmed correct rules at each check,
  but CIDR became stale between checks due to IP rotation
- `ssh -T git@github.com` succeeded, isolating the problem to AWS-side,
  not local network
- `ssh-keygen -yf <pem>` output matched `aws ec2 describe-key-pairs
  --include-public-key` output exactly
- `terraform state show` revealed `key_name = null` on the running instance

## Root Cause
Two independent, sequential root causes:
1. **Dynamic local IP** — ISP-assigned IP changed multiple times during the
   session; each Security Group update was correct at the moment it was
   applied, but stale by the time SSH was attempted.
2. **Incomplete variable wiring** — a `key_name` variable was declared in
   the module's `variables.tf`, giving the *appearance* of being wired
   in, but was never actually referenced in the `aws_instance` resource
   block, and never passed a value from the root module call. Since the
   variable had no default and was unused, Terraform never flagged it as
   missing — it simply had no effect.

## Resolution
- Re-verified current public IP immediately before applying SG changes
  and testing, rather than trusting an earlier-session value
- Added the missing `key_name` reference in both the module resource and
  the root module call
- Forced instance replacement to attach the key pair correctly

## Prevention
- When debugging connectivity, verify the *current* dynamic IP immediately
  before each test — don't reuse a value from earlier in the session
- When wiring a variable through a module boundary, verify it's actually
  *referenced* inside the resource block, not just declared — a declared-
  but-unused required-looking variable can silently do nothing rather than
  error
- Consider AWS Systems Manager Session Manager for future dev access,
  removing the dependency on a stable source IP entirely

## What I initially misunderstood
Assumed that because a variable existed in `variables.tf` with a
sensible name and description, it was automatically wired into the
resource — didn't realize declaration and usage are two separate steps
that both have to be done explicitly.

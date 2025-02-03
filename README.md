# CentOS Workstation

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/79d1f4c2595841bd87f2483ffe1b9340)](https://app.codacy.com/gh/centos-workstation/main/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
[![build-centos-image](https://github.com/centos-workstation/main/actions/workflows/build.yml/badge.svg)](https://github.com/centos-workstation/main/actions/workflows/build.yml)

CentOS Stream-based image with @Workstation preinstalled. How this is expected to be consumed:

```Dockerfile
FROM ghcr.io/centos-workstation/main:latest # (or whatever tag you want)
RUN dnf -y install fastfetch

$your_hopes_and_dreams_go_here.

RUN bootc container lint
```

## Goals

Taking the lessons from [Universal Blue](https://github.com/ublue-os/) but built entirely with [bootc](https://github.com/containers/bootc)

We aim to:

- Facilitate local development with [Just](https://just.systems/) and use it also for CI (so that we have one single correct way to do things)
- Make "main" sleek and as simple as possible to tweak - no "silverblue", "kinoite", "whatever" images, 
just the base, you that the users consume and install the desktops on (we also should provide hardware enablement right from here.)
- Contribute to upstream as much as possible to make it so people arent entirely reliant on workarounds that we provide here (such as upstreaming packages to EPEL, fixing bugs, and whatever else)
- Leverage cloud-native tech to make our stuff MUCH easier, like kernel pinning, easier rollbacks with tons of tags, everything we already do really
- Use [Renovate](https://github.com/apps/renovate) and other automation technologies (like [pull](https://github.com/wei/pull)) to make sure everything is up-to-date and if not, it should be as easy as possible to 
- Enforce strictness and quality assurance as much as possible and prefer stability and correctness over anything else
- Provide hardware enablement through a separate image right from the main repo, without it having to pass through multiple layers
- Have a relatively flat layout for the entire organization, `main` -> `achillobator` and thats it.
- Descope as much stuff as possible, we do NOT need or want to mantain anything if possible

<sub><sup>This is just a draft of this README, please add more stuff here</sup></sub>

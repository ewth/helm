# Scratchpad

Scratch notes. Only really intended for me.

## Conception

Ok so I want to build a project that achieves a few things:

* Is relevant to maritime autonomy.

USVs for days. Staying on the surface for this one. Maybe later venturing under the sea... *under the sea, darling it's better down where it's wetter take it from me do do do do doo doo𝅘𝅥𝅮*

* Refreshes me on ROS2.

It's been a minute since I've worked with ROS2; not being hands-on for a second means it's pretty rusty. I don't want to realise in e.g. an interview situation that I can't remember the specifics of something important.

* Gets me up to speed on more modern ROS2.

Foxy is where I last worked with it, which is long past EOL now; Lyrical is the latest release.

I imagine a bit's changed during F -> G -> H -> I -> J -> K -> L.

It's probably not a great idea to jump to the latest and greatest; industry is unlikely to be at the bleeding edge, and if something changes in significantly in say K, it could actually be adverse to refresh on that.

* Nails down specific versions.

Previous work has largely been project/role-specific and under NDA. So I don't have copies of source code or notes etc from it; I can't look back and say with certainty "it was Gazebo X" or "Blah Y".

Developing something now means I can more readily nail it to specific versions and specific architecture.

* Demonstrates autonomous vehicle understanding.

I've worked with autonomous vehicles; but not in maritime. Aside from much of it being under NDA and it being difficult to speak to specifics, water is a different beast just at surface level, let alone subsurface.

I can scream "I understand perception, I understand localisation, I understand *blah*" from the mountain tops as much as I like; but I don't have a lot that actually demonstrates it.

So I want to demonstrate that.

* Demonstrates simulation understanding.

As above.

* Is interesting and fun.

Because. That's why.

## Development Rig

Modest development rig should be enough to run a reasonable simulation:

* AMD Ryzen 7 5700G.
* NVIDIA RTX 4060 Ti (8GB).
* 32GB RAM.
* SSD storage.
* Ubuntu 24.04.4 LTS.

I want to build the project as containerised (Docker). So anyone can run it, let's just avoid the naive "oh but it works on my machine" dilemma.

## Google-fu

### ROS2 Status

Checking the [ROS2 releases](https://docs.ros.org/en/rolling/Releases.html):

* Foxy: released 2020, EOL 2023.
* Galactic: released 2021, EOL 2022.
* Humble: released 2022, EOL 2027.
* Jazzy: released 2024, EOL 2029.
* Kilted: released 2025, EOL 2026.
* Lyrical: released 2026, EOL 2031.

So Foxy and Galactic have been EOL for a while. Kilted hits EOL this year and obviously isn't a LTS so I'll skip that.

Leaving Humble, Jazzy, Lyrical.

### Gazebo Status

The Gazebo I remember now seems to be called "Gazebo Classic", which was released as a numbered version. "Modern Gazebo" if you will seems to be released as "Gazebo `<Codename>`". I feel like the last version I used had a codename, but I also recall using a numbered release; so can't say exactly where I've been.

It seems there's been some significant architecture changes over the past few years too.

A few LTS versions are still under support per [Gazebo Docs](https://gazebosim.org/docs/latest/releases/):

* Fortress: released 2021, EOL 2027.
* Harmonic: released 2023, EOL 2029.
* Jetty: released 2025, EOL 2031.

So seems Fortress, Harmonic and Jetty are the likely contenders. But it will largely depend which ROS2 version I go with.

### Simulation Environment

After a bit of Googling and filtering through the AI guff, it seems that "Virtual RobotX" (VRX) is a potential sim starting point:

> VRX is an open-source simulation environment designed as a free tool for students to test autonomous maritime robotics solutions.

It's a collaboration between RoboNation, the US Office of Naval Research and the Naval Postgraduate School, and is the basis of a virtual maritime autonomous competition that sits a level below a physical one. It's targetted at university-level teams, and generally seems like a good starting point for personal projects.

It adds the things a generic sim lacks for boats: ocean wave models that affect motion and sensor feedback, wind, 6-DOF surface vessel model, buoyancy, 3D LiDAR that interacts with the water surface, a non-linear thrust model. Basically wraps up the things that I would otherwise need to build to create the "world", and lets me focus on the autonomous unit.

Having a look at the [VRX codebase](https://github.com/osrf/vrx) (currently at commit [7609d1b](https://github.com/osrf/vrx/commit/7609d1bd90ce7edb29d040a082f949e8b089c864)), it notes:

```text
- Code is now working with Gazebo Harmonic and ROS 2 Jazzy
- This is the recommended configuration for new users.
- Users who wish to continue running Gazebo Garden and ROS 2 Humble can still do so using the humble branch of this repository.
```

Latest VRX release is 3.1.2 (Nov 2025). And per release [VRX 3.0.0](https://github.com/osrf/vrx/releases/tag/v3.0.0) (May 2025):

```text
Important

VRX Code is now working with Gazebo Harmonic and ROS 2 Jazzy

This is the recommended configuration for new users. Users who wish to continue running Gazebo Garden and ROS 2 Humble can still do so using the humble branch of this repository.
```

### Which Versions

Now I'm not sure which is the best version to target here.

For ROS2 I'd lean towards Humble as it's the "oldest" LTS and so probably more industry-aligned. But Jazzy could be an option to consider too. Lyrical I think is just too new.

VRX seems like it's a really good sim starting point; having even semi-realistic dynamics would take me in the order of *months* to develop from scratch, and isn't the point of this project.

At the end of the day, what I want to focus on is "building something interesting", not "making sure it's the best possible version for imagined alignment". So I think that settles some of the versioning.

### Settled Software

* ROS2 Jazzy
* Gazebo Harmonic
* VRX 3.1.2
* Docker
* Runs on Ubuntu 24.04.4 LTS
* Everything developed in C++

## Preliminary Overview

VRX takes care of the vessel model, thrust, sensors, world.

I want to develop an autonomous USV on top of that.

So broadly what I'll need to develop is:

* Navigation
* Perception

This breaks down into roughly:

* Localisation: where is the USV?
* Path planning: how does the USV get to X?
* Obstacle avoidance: how does the USV avoid crashing into something?
* Other vessels: how does the USV respond to other vessels (as opposed to static object avoidance)?

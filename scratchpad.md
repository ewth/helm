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

### Additional Note

A specific company that I looked into uses Jazzy. Settles that.

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

For now, I'm going to get it to follow a series of waypoints. It will start at a given point in the VRX environment, then navigate to waypoint A, then to waypoint C, then to waypoint D, etc.

So the problem is essentially: "From position A, how should I navigate to position B".

Localisation will be based on the sensors -- GNSS and IMU. Fusion with an extended Kalman Filter on top.

Broadly, I'm classifying obstacles as two kinds:

1. Static obstacles. Fixed landmarks, things protruding from the water (or only just beneath the surface), rocks, docks, etc.
2. Dynamic obstacles. Things that move, other vessels, people, animals.

Aside from the movement of the USV, I will need to consider other aspects of movement depending on the obstacle.

Now for static obstacles, I will likely need to consider the movement of the environment (largely wind, water). So even if my vessel is "stationary" as far as I can make it, it may still be subject to wind, waves, currents, and so on. This is dependent on how the VRX environment works, and I'll have to dig into it a bit more to ratify.

I will work out whether I only need to consider things that are above the surface of the water (e.g. rocks that stick out of the water), or things that are just below it too (e.g. rocks that don't stick out of the water, but are near enough the surface to crash into). Things above the surface of the water definitely need consideration; things below the surface depend on the specifics of VRX.

For dynamic obstacles, I will need to consider the movement of the environment and the movement of the obstacle. In the event the obstacle is another vessel, I will need to consider how to navigate in line with maritime law. So it might be worth classifying as a third kind (vessels), or simply responding to all dynamic obstacles in the same way. I'll dig into this a bit more later; but from the outset, regardless of what a dynamic obstacle may specifically be, I'm treating the USV as "lowest priority for right of way" -- it looks to navigate around absolutely anything else. This feels more aligned with general autonomous vehicles; don't expect a human to move out of the way, err on the side of safety.

Since a bit of this depends on the specifics of the simulation environment, I'll look to exploring the specifics of it a bit more, before further solidifying the design.

### COLREGs

Specific maritime rules around navigation. This is basically the crux of how to legally navigate on water.

I'm interpreting this here so I can't be 100% certain on my interpretation. But it's a starting point for a simulated project.

Part A covers Rule 1-3:

* Rule 1 (application): all vessels on the high seas and connected navigable waters. Local authorities may make special rules for harbours, rivers and inland waters, conforming as closely as possible; navies may use additional lights and signals.
* Rule 2 (responsibility): nothing excuses neglecting the rules or ordinary seamanship; depart from the rules when necessary to avoid immediate danger.
* Rule 3 (definitions): vessel, power-driven, sailing, fishing, seaplane, WIG craft, not under command, restricted in ability to manoeuvre, constrained by draught, underway, in sight, restricted visibility.

Part B covers three sections:

* Section I Conduct of Vessels in any Condition of Visibility (Rule 4-10).
* Section II Conduct of Vessels in Sight of One Another (Rule 11-18).
* Section III Conduct of Vessels in Restricted Visibility (Rule 19).

In terms of developing an autonomous application on VRX, Part B is of particular relevance:

* Rule 5 (lookout): maintain a proper lookout by sight and hearing and all available means.
* Rule 6 (safe speed): speed appropriate to visibility, traffic, manoeuvrability, sea state.
* Rule 7 (risk of collision): use all available means, including radar; assume risk exists if in doubt.
* Rule 8 (action to avoid collision): action must be positive, made in ample time, and large enough to be readily apparent to the other vessel. Small incremental corrections are explicitly discouraged.
* Rule 9 (narrow channels): keep to the starboard outer limit; vessels under 20 m, sailing vessels and fishing vessels must not impede vessels confined to the channel; don't cross a channel if it impedes; overtaking in a channel requires sound-signal agreement; sound one prolonged blast at blind bends; avoid anchoring.
* Rule 13 (overtaking): the overtaking vessel keeps clear, regardless of vessel type.
* Rule 14 (head-on): both vessels alter course to starboard, passing port to port.
* Rule 15 (crossing): the vessel with the other on her starboard side gives way.
* Rule 16 (give-way vessel): take early and substantial action to keep well clear.
* Rule 17 (stand-on vessel): hold course and speed — but may act if the give-way vessel clearly isn't, and must act if collision can't be avoided by the give-way vessel alone.
* Rule 18 (pecking order): power-driven gives way to sailing, sailing to fishing, and everyone to vessels not under command or restricted in ability to manoeuvre.
* Rule 19 (restricted visibility): no stand-on/give-way distinction; every vessel proceeds at safe speed and avoids altering course to port for a vessel forward of the beam.

I think Rule 19 can be put aside for now. In a simulated environment, fog, smoke, rain, and other natural phenomena that restrict visibility can largely be controlled. I'd like to return to this later on; for the early stage, I think I'll go with high visibility in daylight conditions.

Part C is "Lights and Shapes", and Part D "Sounds and Light Signals". Using the provided vessel model, I'll want to check that it complies; and I might need to consider how to adopt them for identifying other vessels.

To begin with, I'm going to set some simulation constraints to allow adherence to the rules without having to account for absolutely everything:

Phase 1:

* Own-ship only.
* Static obstacles only.
* Open water, away from any channel or marked lane.
* Rules 2, 5, 6, 8 are in force.

Phase 2:

* Add another vessel.
* Same class as USV.
* Behaves as a compliant stand-on vessel.
* USV must give way.
* Rules 7, 13, 14, 15, 16 are added.

Phase 3:

* Add another vessel.
* Same class as USV.
* Behaves as the give-way vessel.
* USV must stand-on.
* Rule 17 added.

Phase 4:

* Add multiple vessels.

Phase 5:

* More complicated environments/visibility.

## VRX 2023 Competition

I was just initially intending to just create a general autonomous USV. But looking further into VRX, the 2023 competition has a series of specific tasks.

Per the [VRX 2023 Wiki](https://github.com/osrf/vrx/wiki/vrx_2023-task_tutorials):

* Task 1: Stationkeeping

> Navigate to the goal pose and hold station. The best solutions will minimize the difference between the goal pose and the actual pose of the vehicle over the duration of the task.

* Task 2: Wayfinding

> Navigate through each of the published waypoints, such that vehicle achieves, as closely as possible, the positions and orientations specified.

* Task 3: Perception

> In this task, the vehicle remains in a fixed location and markers will appear in the field of view. The objective is to use perceptive sensors to identify the markers and report their locations.

* Task 4: Acoustic Perception

> An underwater acoustic beacon broadcasts range, bearing and elevation indicating its position relative to the USV, with noise. The objective of the task is to navigate to the beacon (within 1 m) as quickly as possible.

* Task 5: Wildlife Encounter and Avoid

> This task requires the system to track a heterogeneous set of moving animals representing animal life and plan an appropriate action according to the animal type. The system should plan and traverse a path that
> circles clockwise around platypus markers,
> circles counterclockwise around turtle markers, and
> avoids (i.e. remains at a distance of 10m from) crocodile markers.

* Task 6: Follow the Path

> This task requires the system to traverse a channel marked by pairs of colored buoys, while avoiding obstacles.

* Task 7: Acoustic Tracking

> In this task, the vehicle will track a moving underwater acoustic beacon while avoiding obstacles.

* Task 8: Scan and Dock and Deliver

> Detect the dock and execute a controlled docking maneuver in the appropriate gate. The system should detect the color sequence emitted by the scan-the-code buoy, as this color sequence dictates the correct docking gate. Additional points will be awarded for vehicles that can successfully propel a projectile through one of the two holes in the placard at the head of the correct docking bay.

I think these make a nice set of goals to individually aim for and solve, mitigating scope.

Now to work out what I want the scope of this project to be.

# Godot4 Custom Gravity: A sample project

This repository provides a sample implementation for custom gravity in Godot 4.

[Check out the video I made about this implementation too!](https://youtu.be/7gZzDM-29WQ)

## How it works

A `Gravity` object, e.g. `PointGravity`, is attached to objects that exhibits gravitational forces. It requires a BoundingShape (on collision layer 2). Physical gravity wells also require a `FalloffModel`.

A `BalancePoint` is attached to a gravity-affected object. The object collects gravitational forces acting upon it. Its owner (e.g. `Player.gd`) uses this information to provide gravitationally correct controls.

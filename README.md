# auto_rula

_auto_rula_ implements the functionality for scoring a pose in 3D space
using the [RULA](https://ergo-plus.com/rula-assessment-tool-guide/) system.

## Usage

The main steps for scoring a pose are:

1. **Normalize the pose**: This step normalizes the position, rotation and
scale of the pose in order to the following processing easier.
2. **Project pose onto anatomical planes**: In order to to calculate
joint angles we first project the pose onto the 3 anatomical planes
(coronal, sagittal and transverse).
3. **Calculate joint angles**: Using the normalized pose + the 3 projections
we can now calculate angles of all RULA relevant joints.
4. **Fill out rula-sheet**: We now have all the information to fill out
a modelled RULA sheet, just like in real life.
5. **Score rula-sheet**: We can now run the calculations described in the
RULA system to arrive at scores from the measured angles.

In terms of code, an example pipeline could look like this:

```dart
// Get a pose from somewhere, for example by extracting it from an image
// using computer vision
final Pose pose = getPose();

// Normalize the pose
final NormalizedPose normalized = NormalizedPose.normalize(pose);

// Calculate the joint angles for the pose.
// This requires projecting it onto the anatomical planes.
final PoseAngles angles = PoseAngles.calculate(
    world: normalized,
    coronal: ProjectedPose.coronal(normalized),
    sagittal: ProjectedPose.sagittal(normalized),
    transverse: ProjectedPose.transverse(normalized),
);

// We can now fill out a RULA sheet with the angles we calculated.
final RulaSheet sheet = RulaSheet.fromAngles(angles);

// Finally we can score the sheet.
final RulaScores scores = RulaScores.calculateFor(sheet);
```

For convenience, the package also includes a method which contains this
pipeline if you are only interested in the final score result.

```dart
final pose = getPose();
final scores = pose.score();
```

## License

All source code in this repository is licensed under the
**MIT License with Commons Clause**. This means the software is free to
use, modify, and distribute for non-commercial purposes. However, you may
not sell the software or provide it as part of a commercial service or
paid support offering.

See [LICENSE](./LICENSE) for details.

## Project Status

This library was developed as part of the
[Ergo4All research project](https://research.ustp.at/projekte/ergo4all-ergonomie-fuer-alle).
Originally the code you find in this repository was written in the main
[Ergo4All repository](https://github.com/fhstp/ergo4all). It was chosen to
extract it to it's own package to encourage reuse in other projects.

No further development as part of the Ergo4All project is planned at the
moment.

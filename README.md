# auto_rula

_auto_rula_ implements the functionality for scoring a pose in 3D space
using the RULA system.

A summary of the systems steps are described below:

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

## Usage

In terms of code, an example pipeline could look like this:

```dart
// Get a pose from somewhere, for example by extracting it from an image
// using computer vision
final Pose pose = getPose()

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

# Kitchen Garden

A seasonal planting guide: a catalogue of edible plants plus personal gardens where users track what they grow.

## Language

### Catalogue

**Plant**:
A kind of edible plant in the shared catalogue, with its growing requirements (sun, spacing, sowing windows).
_Avoid_: Vegetable, crop, species

**Sun requirement**:
How much direct sun a Plant needs to grow well: shade, partial shade or full sun.
_Avoid_: Light level

### Gardens

**Garden**:
A user's named growing space, made up of one or more Zones.
_Avoid_: Plot, allotment

**Zone**:
A bounded growing area within a Garden that holds Plant instances; it can be in-ground, raised, a container or a greenhouse.
_Avoid_: Bed, region, area, patch, section

**Plant instance**:
One specific planting of a Plant, growing in exactly one Zone. A Plant can have several, even in the same Zone, each with its own log and plan.
_Avoid_: Garden plant, entry

**Recommendation**:
A Plant proposed for a Zone because of the Plants already growing there, the insects it would attract for them, or the Zone's Sun exposure.
_Avoid_: Suggestion

**Sun exposure**:
How much direct sun a Zone receives, on the same scale as Sun requirement.
_Avoid_: Sun availability, light

**Aspect**:
The compass direction a Zone faces or slopes toward.
_Avoid_: Orientation, direction

**Move**:
Relocating a Plant instance from one Zone to another Zone in the same Garden; recorded in its log.
_Avoid_: Transfer, transplant

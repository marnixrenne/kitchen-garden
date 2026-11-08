# A Plant can have several Plant instances

A Garden used to hold each Plant at most once, a rule that came in with a code-review fix to stop accidental duplicates rather than from a product decision. We dropped it, with no limit even within one Zone, so a Plant can grow in several Zones and be sown in succession; a limit of one per Zone was simpler but would have ruled out succession sowing. Plantings are told apart by their sowing date, and duplicates are prevented in the interface, not the database, so restoring a uniqueness rule would now mean cleaning up data.

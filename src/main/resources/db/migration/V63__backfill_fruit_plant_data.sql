-- V63: Backfill missing data for the 12 Fruit-category plants added in V44.
-- These plants pre-date the script enhancements that populate sowing info,
-- height, and pruning data, so those fields were never seeded.

-- ============================================================
-- SOWING INFO
-- ============================================================

UPDATE pts_plants SET sowing_method = 'direct', spacing_cm = 30,  days_to_maturity_min = 60,   days_to_maturity_max = 90,   frost_tolerance = 'hardy' WHERE name = 'Strawberry';
UPDATE pts_plants SET sowing_method = 'direct', spacing_cm = 45,  days_to_maturity_min = 270,  days_to_maturity_max = 365,  frost_tolerance = 'hardy' WHERE name = 'Raspberry';
UPDATE pts_plants SET sowing_method = 'direct', spacing_cm = 300, days_to_maturity_min = 365,  days_to_maturity_max = 730,  frost_tolerance = 'hardy' WHERE name = 'Blackberry';
UPDATE pts_plants SET sowing_method = 'direct', spacing_cm = 150, days_to_maturity_min = 730,  days_to_maturity_max = 1095, frost_tolerance = 'hardy' WHERE name = 'Blueberry';
UPDATE pts_plants SET sowing_method = 'direct', spacing_cm = 120, days_to_maturity_min = 365,  days_to_maturity_max = 730,  frost_tolerance = 'hardy' WHERE name = 'Gooseberry';
UPDATE pts_plants SET sowing_method = 'direct', spacing_cm = 150, days_to_maturity_min = 365,  days_to_maturity_max = 730,  frost_tolerance = 'hardy' WHERE name = 'Redcurrant';
UPDATE pts_plants SET sowing_method = 'direct', spacing_cm = 150, days_to_maturity_min = 365,  days_to_maturity_max = 730,  frost_tolerance = 'hardy' WHERE name = 'Blackcurrant';
UPDATE pts_plants SET sowing_method = 'direct', spacing_cm = 400, days_to_maturity_min = 1095, days_to_maturity_max = 1825, frost_tolerance = 'hardy' WHERE name = 'Apple';
UPDATE pts_plants SET sowing_method = 'direct', spacing_cm = 400, days_to_maturity_min = 1095, days_to_maturity_max = 1825, frost_tolerance = 'hardy' WHERE name = 'Pear';
UPDATE pts_plants SET sowing_method = 'direct', spacing_cm = 500, days_to_maturity_min = 1095, days_to_maturity_max = 1825, frost_tolerance = 'hardy' WHERE name = 'Cherry';
UPDATE pts_plants SET sowing_method = 'direct', spacing_cm = 400, days_to_maturity_min = 1095, days_to_maturity_max = 1460, frost_tolerance = 'hardy' WHERE name = 'Plum';
UPDATE pts_plants SET sowing_method = 'direct', spacing_cm = 90,  days_to_maturity_min = 365,  days_to_maturity_max = 730,  frost_tolerance = 'hardy' WHERE name = 'Rhubarb';

-- ============================================================
-- HEIGHT
-- ============================================================

UPDATE pts_plants SET height_min_cm = 15,  height_max_cm = 30  WHERE name = 'Strawberry';
UPDATE pts_plants SET height_min_cm = 150, height_max_cm = 200 WHERE name = 'Raspberry';
UPDATE pts_plants SET height_min_cm = 200, height_max_cm = 300 WHERE name = 'Blackberry';
UPDATE pts_plants SET height_min_cm = 100, height_max_cm = 200 WHERE name = 'Blueberry';
UPDATE pts_plants SET height_min_cm = 100, height_max_cm = 150 WHERE name = 'Gooseberry';
UPDATE pts_plants SET height_min_cm = 100, height_max_cm = 150 WHERE name = 'Redcurrant';
UPDATE pts_plants SET height_min_cm = 100, height_max_cm = 180 WHERE name = 'Blackcurrant';
UPDATE pts_plants SET height_min_cm = 200, height_max_cm = 500 WHERE name = 'Apple';
UPDATE pts_plants SET height_min_cm = 200, height_max_cm = 500 WHERE name = 'Pear';
UPDATE pts_plants SET height_min_cm = 200, height_max_cm = 600 WHERE name = 'Cherry';
UPDATE pts_plants SET height_min_cm = 200, height_max_cm = 500 WHERE name = 'Plum';
UPDATE pts_plants SET height_min_cm = 60,  height_max_cm = 120 WHERE name = 'Rhubarb';

-- ============================================================
-- PRUNING
-- ============================================================

UPDATE pts_plants SET pruning_type = 'cutting_back', pruning_tip = 'After harvest, cut back all foliage to 10 cm above the crown and remove any runners not needed for propagation. Replant rooted runners into fresh ground every 3–4 years as fruit production declines with age.' WHERE name = 'Strawberry';
UPDATE pts_plants SET pruning_type = 'cutting_back', pruning_tip = 'For summer-fruiting varieties, cut all canes that have fruited to ground level immediately after harvest and tie in the strongest 6–8 new canes. For autumn-fruiting varieties, cut all canes to ground level in February.' WHERE name = 'Raspberry';
UPDATE pts_plants SET pruning_type = 'cutting_back', pruning_tip = 'Cut all canes that fruited this season to ground level after harvest. Tie in 6–8 of the strongest new canes and remove the rest. Tip new canes at approximately 1.8 m in winter to encourage fruiting side shoots the following year.' WHERE name = 'Blackberry';
UPDATE pts_plants SET pruning_type = 'cutting_back', pruning_tip = 'For the first two years, remove all flowers to let the plant establish. From year three onward, prune in late winter: remove dead and crossing branches, and cut one quarter of the oldest stems to ground level annually to encourage productive new growth.' WHERE name = 'Blueberry';
UPDATE pts_plants SET pruning_type = 'cutting_back', pruning_tip = 'Prune in late winter into an open goblet shape to improve airflow and reduce powdery mildew. Remove one third of the oldest stems to ground level annually. Shorten all main branches by a quarter and reduce side shoots to 2–3 buds.' WHERE name = 'Gooseberry';
UPDATE pts_plants SET pruning_type = 'cutting_back', pruning_tip = 'In late winter, shorten all new side shoots to one bud from the main branch and reduce the main leaders by a quarter. Redcurrants fruit on old wood — maintain the permanent framework and only remove dead, diseased, or crossing stems.' WHERE name = 'Redcurrant';
UPDATE pts_plants SET pruning_type = 'cutting_back', pruning_tip = 'Cut one third of the oldest, darkest stems to ground level each year immediately after fruiting. Unlike redcurrants, blackcurrants produce their best fruit on young wood — removing old wood annually keeps the plant productive.' WHERE name = 'Blackcurrant';
UPDATE pts_plants SET pruning_type = 'cutting_back', pruning_tip = 'Prune in winter while the tree is fully dormant. In the first three years, build a balanced framework of main branches. On established trees, remove dead, diseased, and crossing wood, shorten new side shoots to 4–6 buds, and reduce older laterals to spurs. Thin fruit clusters to one fruit per spur in June.' WHERE name = 'Apple';
UPDATE pts_plants SET pruning_type = 'cutting_back', pruning_tip = 'Prune in winter while the tree is fully dormant. Pears fruit on spurs on older wood — maintain a permanent framework. In summer, shorten new laterals to 6 leaves; in winter cut these back to 2–3 buds. Avoid hard pruning, which stimulates leafy water shoots that do not fruit.' WHERE name = 'Pear';
UPDATE pts_plants SET pruning_type = 'cutting_back', pruning_tip = 'Prune cherries in late spring or summer only — cuts made in autumn or winter risk silver leaf disease and canker. Remove dead, diseased, and crossing branches. On fan-trained trees, tie in new growth and remove shoots growing directly toward or away from the wall.' WHERE name = 'Cherry';
UPDATE pts_plants SET pruning_type = 'cutting_back', pruning_tip = 'Prune in summer only — never in winter, as silver leaf disease enters through cuts made in cold, wet conditions. Remove dead, diseased, and crossing branches. Thin heavy crops by hand in June to prevent branch breakage. Remove any suckers that appear from the base.' WHERE name = 'Plum';
UPDATE pts_plants SET pruning_type = 'cutting_back', pruning_tip = 'Remove any flowering stems as soon as they appear — allowing rhubarb to flower significantly reduces the following year''s yield. Cut back all dead foliage to ground level in autumn. To force early stems, cover crowns with a pot or upturned bucket in late winter.' WHERE name = 'Rhubarb';

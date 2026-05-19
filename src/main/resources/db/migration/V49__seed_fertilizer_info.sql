-- Fertilizer types:
--   heavy_feeder    – regular liquid feeding throughout the growing season
--   moderate_feeder – feeding at key growth stages (planting, flowering, fruiting)
--   light_feeder    – enrich soil before planting; minimal extra feeding
--   none            – no fertiliser needed (legumes, plants preferring lean soil)

-- ============================================================
-- FRUITING VEGETABLES
-- ============================================================

UPDATE pts_plants SET fertilizer_type = 'heavy_feeder',
    fertilizer_tip = 'Incorporate a balanced granular fertiliser into the bed at planting. Once the first truss has set, switch to a high-potassium liquid feed every 7–14 days — this supports fruiting and prevents blossom-end rot. Continue until the last trusses start to colour.'
WHERE name = 'Tomato';

UPDATE pts_plants SET fertilizer_type = 'heavy_feeder',
    fertilizer_tip = 'Mix a balanced fertiliser or well-rotted compost into the bed before planting. Once flowering begins, feed every 7–10 days with a high-potassium liquid fertiliser to sustain continuous fruiting through the season.'
WHERE name = 'Cucumber';

UPDATE pts_plants SET fertilizer_type = 'heavy_feeder',
    fertilizer_tip = 'Incorporate a balanced granular fertiliser before transplanting. Once flowers appear, switch to a high-potassium liquid feed every 10–14 days. Consistent feeding produces a much heavier crop than unfed plants.'
WHERE name IN ('Bell Pepper', 'Chili Pepper', 'Jalapeño', 'Habanero', 'Cayenne Pepper');

UPDATE pts_plants SET fertilizer_type = 'heavy_feeder',
    fertilizer_tip = 'Work compost or a balanced fertiliser into the bed before planting. Once the first fruits have set, apply a high-potassium liquid feed every 2 weeks to sustain the heavy cropping throughout summer.'
WHERE name = 'Zucchini';

UPDATE pts_plants SET fertilizer_type = 'heavy_feeder',
    fertilizer_tip = 'Apply a balanced fertiliser or well-rotted compost before planting. Switch to a high-potassium liquid feed every 2 weeks once the first fruits have set, to support the development of large, well-filled fruits.'
WHERE name IN ('Pumpkin', 'Squash', 'Butternut Squash', 'Kabocha', 'Spaghetti Squash');

UPDATE pts_plants SET fertilizer_type = 'heavy_feeder',
    fertilizer_tip = 'Apply a balanced fertiliser before planting and switch to a high-potassium liquid feed every 2 weeks once the first fruits have set. Limit to 2–3 fruits per plant and keep the soil consistently moist to support even growth.'
WHERE name = 'Watermelon';

UPDATE pts_plants SET fertilizer_type = 'heavy_feeder',
    fertilizer_tip = 'Apply a nitrogen-rich fertiliser before sowing or work a balanced granular feed into the bed at planting. Top-dress with a nitrogen-rich liquid feed when plants reach knee height to fuel rapid stem and leaf growth.'
WHERE name = 'Sweetcorn';

UPDATE pts_plants SET fertilizer_type = 'heavy_feeder',
    fertilizer_tip = 'Incorporate a balanced granular fertiliser before transplanting. Once flowering begins, switch to a high-potassium liquid feed every 10–14 days to maximise fruit set and individual fruit size.'
WHERE name = 'Eggplant';

UPDATE pts_plants SET fertilizer_type = 'heavy_feeder',
    fertilizer_tip = 'Incorporate a balanced granular fertiliser before transplanting. Once flowering begins, switch to a high-potassium liquid feed every 10–14 days. Regular feeding significantly increases yield compared with unfed plants.'
WHERE name = 'Tomatillo';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Work a balanced fertiliser into the bed before planting. Feed every 2–3 weeks with a balanced liquid fertiliser once plants are established, switching to a lower-nitrogen, higher-potassium formulation once flowering begins.'
WHERE name = 'Okra';

UPDATE pts_plants SET fertilizer_type = 'heavy_feeder',
    fertilizer_tip = 'Apply a balanced fertiliser or compost before planting. Once fruiting begins, feed every 7–10 days with a high-potassium liquid fertiliser — luffa fruits are large and the plant needs sustained nutrition to produce well.'
WHERE name = 'Luffa';

-- ============================================================
-- LEAFY VEGETABLES
-- ============================================================

UPDATE pts_plants SET fertilizer_type = 'light_feeder',
    fertilizer_tip = 'Incorporate compost or a balanced granular fertiliser before sowing. A dilute liquid feed every 3–4 weeks during the growing season keeps leaves lush, but avoid high-nitrogen feeds close to harvest as they reduce flavour.'
WHERE name = 'Lettuce';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Work compost or a balanced granular fertiliser into the bed before sowing. A nitrogen-rich liquid feed every 3–4 weeks during active growth supports the rapid leafy development spinach needs.'
WHERE name = 'Spinach';

UPDATE pts_plants SET fertilizer_type = 'light_feeder',
    fertilizer_tip = 'Enrich the soil with a little compost before sowing. Rocket rarely needs additional feeding — high nitrogen produces lush but bland, low-flavour leaves. If growth is very slow, a single dilute liquid feed is sufficient.'
WHERE name = 'Rocket';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Incorporate compost or a balanced fertiliser before sowing. A liquid nitrogen feed every 3–4 weeks supports the vigorous leaf and stem growth Swiss chard produces over its long season.'
WHERE name = 'Swiss Chard';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Incorporate compost before sowing. A dilute liquid feed monthly during active growth keeps leaves productive. Sorrel is a perennial — a top-dress of compost each spring reduces the need for liquid feeding.'
WHERE name = 'Sorrel';

UPDATE pts_plants SET fertilizer_type = 'light_feeder',
    fertilizer_tip = 'Incorporate a little compost before sowing. Mizuna is a fast-growing leafy crop that rarely needs additional fertiliser in reasonable soil. A single dilute liquid feed mid-season is enough if growth slows.'
WHERE name = 'Mizuna';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Enrich the bed with compost before sowing. A dilute balanced liquid feed every 3–4 weeks helps maintain a continuous supply of productive leaves through its long season.'
WHERE name IN ('Bok Choy', 'Lamb''s Lettuce', 'Endive', 'Radicchio', 'Chicory');

UPDATE pts_plants SET fertilizer_type = 'none',
    fertilizer_tip = 'No fertiliser needed. Borage is a vigorous self-seeder that thrives in average to poor soil — excess nutrients lead to soft, floppy, pest-prone growth and fewer flowers.'
WHERE name = 'Borage';

UPDATE pts_plants SET fertilizer_type = 'heavy_feeder',
    fertilizer_tip = 'Apply a balanced granular fertiliser or well-rotted compost in early spring as growth resumes. Feed monthly during active growth with a balanced liquid fertiliser — artichoke is a large, hungry plant that produces best with sustained nutrition.'
WHERE name IN ('Artichoke', 'Cardoon');

-- ============================================================
-- BRASSICAS
-- ============================================================

UPDATE pts_plants SET fertilizer_type = 'heavy_feeder',
    fertilizer_tip = 'Kale is a hungry brassica. Incorporate nitrogen-rich compost or well-rotted manure before planting. Top-dress with a balanced granular fertiliser or liquid nitrogen feed mid-season to support the heavy leaf growth over its long season.'
WHERE name IN ('Kale', 'Lacinato Kale', 'Collard Greens');

UPDATE pts_plants SET fertilizer_type = 'heavy_feeder',
    fertilizer_tip = 'Incorporate well-rotted manure or a balanced granular fertiliser before planting. Top-dress once with a nitrogen-rich liquid or granular feed about 4–6 weeks after transplanting to drive the formation of a tight, heavy head.'
WHERE name IN ('Cabbage', 'Napa Cabbage');

UPDATE pts_plants SET fertilizer_type = 'heavy_feeder',
    fertilizer_tip = 'Work nitrogen-rich compost or a balanced granular fertiliser into the bed before planting. Apply a liquid nitrogen feed 4–6 weeks after transplanting to swell the central head and support productive side shoots after the main harvest.'
WHERE name = 'Broccoli';

UPDATE pts_plants SET fertilizer_type = 'heavy_feeder',
    fertilizer_tip = 'Incorporate well-rotted manure or a high-nitrogen granular fertiliser before planting. Top-dress once with a balanced liquid feed 4–6 weeks after transplanting — cauliflower needs consistently high nutrients to form a well-developed, compact curd.'
WHERE name = 'Cauliflower';

UPDATE pts_plants SET fertilizer_type = 'heavy_feeder',
    fertilizer_tip = 'Incorporate nitrogen-rich compost or well-rotted manure before planting. Apply a nitrogen-rich liquid feed 6–8 weeks after transplanting and a second feed in midsummer to support the long growing season and the swelling of the sprouts.'
WHERE name = 'Brussels Sprouts';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Work compost into the bed before planting. A balanced liquid feed every 3–4 weeks during active growth supports the rapid swelling of the kohlrabi stem. Harvest promptly — overgrown bulbs become woody regardless of feeding.'
WHERE name = 'Kohlrabi';

UPDATE pts_plants SET fertilizer_type = 'light_feeder',
    fertilizer_tip = 'Sow into ground with moderate fertility. A light balanced fertiliser before sowing is enough — turnips do not need heavy feeding and excess nitrogen produces leafy tops at the expense of root development.'
WHERE name = 'Turnip';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Incorporate compost or a balanced granular fertiliser before sowing. A liquid nitrogen feed when plants are half grown supports the leafy growth rapini produces before it runs to flower.'
WHERE name = 'Rapini';

-- ============================================================
-- ROOT VEGETABLES
-- ============================================================

UPDATE pts_plants SET fertilizer_type = 'light_feeder',
    fertilizer_tip = 'Sow into ground that has had compost incorporated for a previous crop. Avoid fresh manure or high-nitrogen fertilisers — they cause roots to fork and produce an excess of leafy top growth. No further feeding is needed.'
WHERE name IN ('Carrot', 'Parsnip', 'Daikon');

UPDATE pts_plants SET fertilizer_type = 'light_feeder',
    fertilizer_tip = 'No fertiliser needed if the soil has reasonable fertility. Rich or freshly manured soil leads to excess leafy growth and poor root development. Sow into ground prepared for a previous crop.'
WHERE name = 'Radish';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Incorporate a balanced fertiliser or compost before sowing. A dilute balanced liquid feed every 3–4 weeks from mid-season encourages steady root swelling. Avoid high-nitrogen feeds, which favour leafy tops over root development.'
WHERE name = 'Beetroot';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Work compost into the bed before planting. Apply a nitrogen-rich liquid feed in spring while the leaves are actively growing. Stop feeding once the bulbs begin to swell — late feeding produces soft bulbs that store poorly.'
WHERE name IN ('Onion', 'Shallot');

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Enrich the bed with well-rotted compost before transplanting. Apply a balanced liquid fertiliser once or twice during the growing season — a feed in midsummer and again in early autumn supports steady growth through to winter harvest.'
WHERE name = 'Leek';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Work compost into the bed before planting. Apply a nitrogen-rich liquid feed in autumn to support bulb development over winter. In spring, a single balanced feed encourages the final swelling before harvest.'
WHERE name = 'Garlic';

UPDATE pts_plants SET fertilizer_type = 'light_feeder',
    fertilizer_tip = 'Incorporate a little compost before planting. Spring onions grow quickly and rarely need additional feeding. In poor soil, a single dilute liquid feed 3–4 weeks after sowing is enough.'
WHERE name = 'Spring Onion';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Apply a balanced fertiliser before planting. Avoid high nitrogen once haulms are established — switch to a higher-potassium feed at earthing-up time to support tuber development and improve skin quality.'
WHERE name = 'Potato';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Apply a balanced fertiliser before planting. Avoid excess nitrogen — high-nitrogen feeding promotes vine growth at the expense of tubers. A potassium-rich feed from midsummer supports sweet potato root development.'
WHERE name = 'Sweet Potato';

UPDATE pts_plants SET fertilizer_type = 'heavy_feeder',
    fertilizer_tip = 'Celery is a very hungry crop. Incorporate well-rotted manure or a balanced granular fertiliser before planting. Feed every 2–3 weeks with a liquid balanced fertiliser throughout the season — without consistent feeding, stalks remain thin and tough.'
WHERE name = 'Celery';

UPDATE pts_plants SET fertilizer_type = 'heavy_feeder',
    fertilizer_tip = 'Celeriac is as hungry as celery. Incorporate well-rotted manure or a balanced granular fertiliser before planting. Feed every 2–3 weeks with a balanced liquid fertiliser to support the swelling of the large, dense root.'
WHERE name = 'Celeriac';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Apply a balanced granular fertiliser in spring as spears emerge. After the harvest season ends, top-dress with a high-potassium feed or well-rotted compost to build crown reserves for the following year. Do not harvest in the first 2 years.'
WHERE name = 'Asparagus';

UPDATE pts_plants SET fertilizer_type = 'light_feeder',
    fertilizer_tip = 'Incorporate compost before planting, but avoid high-nitrogen feeds — this vigorous, spreading plant rarely needs additional fertiliser once established in reasonably fertile soil.'
WHERE name = 'Jerusalem Artichoke';

-- ============================================================
-- LEGUMES
-- ============================================================

UPDATE pts_plants SET fertilizer_type = 'none',
    fertilizer_tip = 'Peas are nitrogen-fixing legumes that do not need nitrogen fertiliser. Incorporate well-rotted compost before sowing for soil structure only. A potassium-rich liquid feed once flowering begins can improve pod set, though it is rarely necessary in fertile soil.'
WHERE name IN ('Pea', 'Snap Pea');

UPDATE pts_plants SET fertilizer_type = 'none',
    fertilizer_tip = 'Beans fix their own nitrogen and need no nitrogen fertiliser — excess nitrogen promotes leafy growth at the expense of pods. Incorporate compost before sowing for soil structure, and water rather than feed during dry spells.'
WHERE name IN ('Bean', 'Runner Bean', 'Broad Bean', 'Asparagus Bean');

UPDATE pts_plants SET fertilizer_type = 'none',
    fertilizer_tip = 'Soybeans fix atmospheric nitrogen and thrive without added fertiliser. Incorporate well-rotted compost for soil structure before sowing. Any nitrogen feed will push the plant into vegetative growth at the expense of pods.'
WHERE name = 'Soybean';

UPDATE pts_plants SET fertilizer_type = 'none',
    fertilizer_tip = 'Lentils are nitrogen-fixers that need no nitrogen fertiliser. Sow into moderately fertile, well-drained soil with compost incorporated. Excess fertility leads to floppy stems and poor pod production.'
WHERE name = 'Lentil';

-- ============================================================
-- HERBS
-- ============================================================

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Incorporate compost or a balanced granular fertiliser before sowing. A dilute balanced liquid feed every 3–4 weeks during the growing season keeps the plant lush and productive, especially after a hard cut-back.'
WHERE name = 'Parsley';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Incorporate compost or a balanced granular fertiliser before planting. A dilute liquid feed every 3–4 weeks from midsummer maintains lush growth, especially after pinching back flower stems.'
WHERE name = 'Basil';

UPDATE pts_plants SET fertilizer_type = 'light_feeder',
    fertilizer_tip = 'Incorporate a little compost before sowing. Dill thrives in moderately fertile, well-drained soil and does not need regular feeding — high nitrogen produces lush, soft growth that bolts quickly.'
WHERE name = 'Dill';

UPDATE pts_plants SET fertilizer_type = 'light_feeder',
    fertilizer_tip = 'Incorporate compost into the bed before planting. Fennel rarely needs additional feeding once established. Avoid high-nitrogen fertilisers, which promote leafy growth at the expense of aromatic oils and seed production.'
WHERE name = 'Fennel';

UPDATE pts_plants SET fertilizer_type = 'light_feeder',
    fertilizer_tip = 'Incorporate a little compost before sowing or planting. Coriander grows quickly and rarely benefits from regular feeding. High nitrogen causes it to bolt even faster than usual — if anything, lean soil prolongs the leaf harvest.'
WHERE name = 'Coriander';

UPDATE pts_plants SET fertilizer_type = 'light_feeder',
    fertilizer_tip = 'Chives are adaptable and perform well in average soil with compost incorporated before planting. A light balanced feed in spring after cutting back encourages a strong flush of new growth. No further feeding is needed.'
WHERE name = 'Chive';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Incorporate compost before planting. Mint is a vigorous grower and benefits from a balanced liquid feed every 3–4 weeks during active growth. After each hard cut-back, a dilute feed encourages fast, fresh regrowth.'
WHERE name = 'Mint';

UPDATE pts_plants SET fertilizer_type = 'none',
    fertilizer_tip = 'Mediterranean herbs thrive in lean, well-drained soil and should not be fertilised regularly. Incorporate a small amount of compost at planting. Avoid nitrogen-rich feeds — they produce soft, frost-tender growth with reduced essential oil concentration and fragrance.'
WHERE name IN ('Thyme', 'Rosemary', 'Sage', 'Oregano');

UPDATE pts_plants SET fertilizer_type = 'light_feeder',
    fertilizer_tip = 'Caraway grows well in average fertile soil with compost incorporated before sowing. No regular feeding is needed — this biennial herb produces well without supplementary fertiliser in most garden soils.'
WHERE name = 'Caraway';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Incorporate compost before planting. Lemongrass is a heavy tropical grass that benefits from a balanced liquid feed every 3–4 weeks during the growing season, especially in containers where nutrients deplete more quickly.'
WHERE name = 'Lemongrass';

UPDATE pts_plants SET fertilizer_type = 'light_feeder',
    fertilizer_tip = 'Incorporate a little compost before planting. Tarragon prefers a moderately fertile, well-drained soil and does not need regular feeding. A single light balanced feed in early spring is enough to start the season.'
WHERE name = 'Tarragon';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Incorporate compost or a balanced granular fertiliser before planting. Lovage is a very vigorous grower that benefits from a balanced liquid feed monthly during active growth. After cutting back hard in midsummer, a liquid feed encourages strong regrowth.'
WHERE name = 'Lovage';

-- ============================================================
-- FLOWERS
-- ============================================================

UPDATE pts_plants SET fertilizer_type = 'none',
    fertilizer_tip = 'Do not fertilise nasturtiums. They thrive in poor soil and produce their best flowers in lean conditions — rich soil or added nutrients encourage lush leafy growth at the expense of blooms.'
WHERE name = 'Nasturtium';

UPDATE pts_plants SET fertilizer_type = 'light_feeder',
    fertilizer_tip = 'Incorporate compost or a balanced granular fertiliser before sowing. Calendula is undemanding but a dilute liquid feed every 3–4 weeks extends the flowering season significantly, especially after deadheading.'
WHERE name = 'Calendula';

UPDATE pts_plants SET fertilizer_type = 'none',
    fertilizer_tip = 'Lavender thrives in lean, well-drained soil and should not be fertilised. High nitrogen produces soft, frost-tender growth and far fewer flowers. Avoid organic matter-rich or moisture-retentive soil — lean and gritty is ideal.'
WHERE name = 'Lavender';

UPDATE pts_plants SET fertilizer_type = 'light_feeder',
    fertilizer_tip = 'Incorporate compost or a balanced granular fertiliser before planting. A dilute balanced liquid feed every 4 weeks during the flowering season extends the display. Avoid high-nitrogen feeds, which produce leafy growth at the expense of flowers.'
WHERE name = 'Viola';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Incorporate a balanced fertiliser into the bed before sowing. Feed every 3–4 weeks with a balanced liquid fertiliser once the plant is established — sunflowers are fast-growing and benefit from consistent nutrition to produce large heads.'
WHERE name = 'Sunflower';

UPDATE pts_plants SET fertilizer_type = 'none',
    fertilizer_tip = 'Cornflowers prefer poor to moderately fertile soil and do not need fertilising. Rich soil or added nutrients produce floppy stems and fewer blooms. Sow into ground not recently enriched with manure or compost.'
WHERE name = 'Cornflower';

UPDATE pts_plants SET fertilizer_type = 'none',
    fertilizer_tip = 'Chamomile thrives in poor, lean soil and produces its most aromatic flowers without additional feeding. Fertilising produces lush but less fragrant growth. No supplementary feeding is needed.'
WHERE name = 'Chamomile';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Apply a balanced granular fertiliser in early spring as growth begins. After flowering, top-dress with well-rotted compost to support the development of the following year''s wood. Avoid high-nitrogen feeds in late summer as they produce soft growth vulnerable to frost.'
WHERE name = 'Elderflower';

UPDATE pts_plants SET fertilizer_type = 'heavy_feeder',
    fertilizer_tip = 'Apply a balanced granular rose fertiliser in early spring as growth resumes and again after the first flush of flowers. Feed every 4–6 weeks through summer with a liquid rose fertiliser containing potassium and magnesium. Stop feeding in late summer to allow wood to harden before winter.'
WHERE name = 'Rose';

-- ============================================================
-- FRUIT
-- ============================================================

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Apply a balanced granular fertiliser in early spring as growth resumes. Once flowering begins, switch to a high-potassium liquid feed every 2 weeks to maximise fruit production. Stop feeding after harvest and allow the plant to harden off before winter.'
WHERE name = 'Strawberry';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Apply a balanced granular fertiliser or well-rotted manure in early spring before growth begins. Top-dress with a potassium-rich feed after fruiting to support new cane development for the following season. Avoid high-nitrogen feeds in late summer.'
WHERE name IN ('Raspberry', 'Blackberry');

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Blueberries require acidic soil (pH 4.5–5.5) and must be fed with an ericaceous (acid-loving plant) fertiliser in early spring. Avoid lime-based or high-phosphorus fertilisers, and never add wood ash near blueberries as it raises soil pH.'
WHERE name = 'Blueberry';

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Apply a balanced granular fertiliser in early spring before bud burst. A light top-dressing of well-rotted compost in autumn helps maintain soil structure and provides nutrition for the following season.'
WHERE name IN ('Gooseberry', 'Redcurrant', 'Blackcurrant');

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Apply a balanced granular fertiliser in early spring around the drip line of the tree. Avoid high-nitrogen feeds after early summer — this promotes soft late-season growth that is vulnerable to frost, fire blight, and other diseases.'
WHERE name IN ('Apple', 'Pear', 'Cherry', 'Plum');

UPDATE pts_plants SET fertilizer_type = 'moderate_feeder',
    fertilizer_tip = 'Apply a balanced granular fertiliser or well-rotted manure each spring as growth resumes. A second top-dressing of compost in midsummer helps sustain production through the main harvest period. Do not feed or harvest in the first year after planting to allow the crown to establish.'
WHERE name = 'Rhubarb';

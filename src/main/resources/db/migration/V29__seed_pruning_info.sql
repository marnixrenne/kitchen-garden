-- Pruning types:
--   pinching     – pinch out growing tips or flower buds
--   suckering    – remove side shoots (tomato-style)
--   topping      – remove main growing tip at target height
--   cutting_back – hard prune to rejuvenate or tidy
--   deadheading  – remove spent flowers
--   leaf_removal – remove old / damaged / yellowing leaves

UPDATE vegetables SET pruning_type = 'suckering',
    pruning_tip = 'Remove side shoots (suckers) developing in leaf axils weekly. For cordon varieties, pinch out the growing tip above the 4th–6th truss to limit the plant to a manageable height.'
WHERE name = 'Tomato';

UPDATE vegetables SET pruning_type = 'suckering',
    pruning_tip = 'Train as a cordon and remove all side shoots beyond the second leaf. Pinch out the main tip after 6–7 leaves on bush varieties to encourage branching.'
WHERE name = 'Cucumber';

UPDATE vegetables SET pruning_type = 'pinching',
    pruning_tip = 'Pinch out the first flower bud (crown bud) that appears in the fork of the main stem to build a stronger, more branched plant before fruiting begins.'
WHERE name = 'Bell Pepper';

UPDATE vegetables SET pruning_type = 'pinching',
    pruning_tip = 'Pinch out the first flower buds to encourage a stronger branching structure. Once fruiting begins, no further pruning is needed.'
WHERE name = 'Chili Pepper';

UPDATE vegetables SET pruning_type = 'pinching',
    pruning_tip = 'Pinch out the first flower buds to build a better-branching plant. Remove any side shoots on the lower third of the stem for airflow.'
WHERE name IN ('Jalapeño', 'Habanero', 'Cayenne Pepper');

UPDATE vegetables SET pruning_type = 'topping',
    pruning_tip = 'Pinch out the growing tip after 2–3 fruits have set to stop the plant extending and direct energy into ripening those fruits. Shorten side shoots to two leaves beyond a fruit.'
WHERE name IN ('Pumpkin', 'Squash', 'Butternut Squash', 'Kabocha', 'Spaghetti Squash');

UPDATE vegetables SET pruning_type = 'topping',
    pruning_tip = 'Limit to 2–3 fruits per plant by removing additional female flowers once the desired number have set. Pinch out all growing tips to direct energy into ripening.'
WHERE name = 'Watermelon';

UPDATE vegetables SET pruning_type = 'topping',
    pruning_tip = 'Pinch out the growing tip after 5–6 fruits have set to concentrate energy on ripening and improve individual fruit size.'
WHERE name = 'Eggplant';

UPDATE vegetables SET pruning_type = 'topping',
    pruning_tip = 'Pinch out the growing tip after 5–6 fruits have set to encourage ripening. Remove any fruits that set very late in the season as they will not have time to mature.'
WHERE name = 'Tomatillo';

UPDATE vegetables SET pruning_type = 'topping',
    pruning_tip = 'Pinch out the growing tip when plants reach the top of their support structure to redirect energy from further stem growth into pod production.'
WHERE name = 'Runner Bean';

UPDATE vegetables SET pruning_type = 'topping',
    pruning_tip = 'Pinch out the growing tip when plants reach the top of their support to encourage pod set and reduce the risk of wind damage.'
WHERE name = 'Asparagus Bean';

UPDATE vegetables SET pruning_type = 'topping',
    pruning_tip = 'Pinch out the growing tip when the plant reaches 60–90 cm to encourage lateral branching and create more flowering sites.'
WHERE name = 'Okra';

UPDATE vegetables SET pruning_type = 'topping',
    pruning_tip = 'Cut the tops when plants reach 1.5–2 m to reduce wind rock and encourage the plant to put more energy into tuber development.'
WHERE name = 'Jerusalem Artichoke';

UPDATE vegetables SET pruning_type = 'pinching',
    pruning_tip = 'Pinch out the top 5–8 cm of growing tips once the first pods have set. This deters blackfly — which congregate on soft growing tips — and improves pod fill.'
WHERE name = 'Broad Bean';

UPDATE vegetables SET pruning_type = 'pinching',
    pruning_tip = 'Pinch out flower buds as soon as they appear to keep leaves productive and flavourful. If the plant becomes leggy, cut back by a third to encourage bushy new growth.'
WHERE name = 'Basil';

UPDATE vegetables SET pruning_type = 'pinching',
    pruning_tip = 'Pinch out the central stem tip when the plant is young to encourage a bushy habit and delay bolting. Remove flower stems immediately if they appear.'
WHERE name = 'Coriander';

UPDATE vegetables SET pruning_type = 'pinching',
    pruning_tip = 'Pinch out flower heads as they form to prolong the leaf harvest. If growing for seeds, allow a few stems to flower and set seed, then remove before they drop.'
WHERE name = 'Dill';

UPDATE vegetables SET pruning_type = 'pinching',
    pruning_tip = 'Remove flower heads as they form to extend the leaf harvest. Allow one or two stems to flower and seed if collecting for culinary or sowing use.'
WHERE name = 'Fennel';

UPDATE vegetables SET pruning_type = 'cutting_back',
    pruning_tip = 'Cut back hard to 5 cm above the ground 2–3 times per season to keep growth fresh and prevent the plant from becoming woody and invasive. Contain in a pot to prevent spreading.'
WHERE name = 'Mint';

UPDATE vegetables SET pruning_type = 'cutting_back',
    pruning_tip = 'Trim lightly after flowering each year to keep the plant tidy. Every 2–3 years, prune more firmly in spring — but never cut back into old brown wood as it will not regrow.'
WHERE name = 'Thyme';

UPDATE vegetables SET pruning_type = 'cutting_back',
    pruning_tip = 'Trim lightly after flowering. Never cut back into old wood as rosemary will not regrow from bare stems. Replace the plant every 5–7 years when it becomes too woody.'
WHERE name = 'Rosemary';

UPDATE vegetables SET pruning_type = 'cutting_back',
    pruning_tip = 'Cut back by one third in early spring and lightly again after flowering to keep the plant compact. Replace every 4–5 years as it becomes woody.'
WHERE name = 'Sage';

UPDATE vegetables SET pruning_type = 'cutting_back',
    pruning_tip = 'Cut back to just above the base in spring and again lightly after flowering to encourage a second flush of growth. Oregano benefits from being divided every 3–4 years.'
WHERE name = 'Oregano';

UPDATE vegetables SET pruning_type = 'cutting_back',
    pruning_tip = 'Cut back to 5 cm above the ground 2–3 times during the growing season to encourage fresh, tender regrowth. Chives also benefit from division every 3–4 years.'
WHERE name = 'Chive';

UPDATE vegetables SET pruning_type = 'cutting_back',
    pruning_tip = 'Cut back to ground level 2–3 times per season to prevent flowering and keep the leaves young and tender. Sorrel is a perennial that will reshoot vigorously after cutting.'
WHERE name = 'Sorrel';

UPDATE vegetables SET pruning_type = 'cutting_back',
    pruning_tip = 'Cut back to 10 cm above the base in early spring or before bringing indoors for winter. In frost-free climates it can be left year-round and cut back in early spring.'
WHERE name = 'Lemongrass';

UPDATE vegetables SET pruning_type = 'cutting_back',
    pruning_tip = 'Cut all ferns back to ground level in autumn once they turn yellow and die back. Do not harvest any spears in the first two years to allow the crown to establish.'
WHERE name = 'Asparagus';

UPDATE vegetables SET pruning_type = 'cutting_back',
    pruning_tip = 'Trim lightly after the first flush of growth in spring. Cut back harder every few years to prevent the plant becoming woody. Caraway is biennial — cut back the first year to prevent premature flowering.'
WHERE name = 'Caraway';

UPDATE vegetables SET pruning_type = 'deadheading',
    pruning_tip = 'Harvest the central head before the flower bracts open. Leave the stem and cut side shoots as they develop — a single plant can produce for several weeks after the main head is taken.'
WHERE name IN ('Artichoke', 'Cardoon');

UPDATE vegetables SET pruning_type = 'deadheading',
    pruning_tip = 'Remove spent flowers regularly to extend flowering and prevent the plant self-seeding aggressively throughout the garden.'
WHERE name = 'Borage';

UPDATE vegetables SET pruning_type = 'leaf_removal',
    pruning_tip = 'Remove old, yellowing or mildewed leaves at the base to improve airflow and reduce disease pressure. Keep 4–6 healthy leaves on the plant at all times.'
WHERE name = 'Zucchini';

UPDATE vegetables SET pruning_type = 'leaf_removal',
    pruning_tip = 'Snap off yellowing lower leaves as the plant grows upwards. This improves airflow, reduces slug habitat at the base, and keeps energy directed into sprout development.'
WHERE name = 'Brussels Sprouts';

UPDATE vegetables SET pruning_type = 'leaf_removal',
    pruning_tip = 'Harvest outer leaves regularly — this acts as natural pruning. Remove yellowing or damaged leaves promptly to prevent disease spreading through the plant.'
WHERE name IN ('Kale', 'Collard Greens');

UPDATE vegetables SET pruning_type = 'leaf_removal',
    pruning_tip = 'Remove yellowing outer stalks and any damaged growth as the season progresses, to keep energy focused on producing tender inner stems.'
WHERE name = 'Celery';

UPDATE vegetables SET pruning_type = 'leaf_removal',
    pruning_tip = 'Remove outer leaves as they age and cut away any side growth to keep energy focused on swelling the celeriac base. A little light can be admitted to the developing root.'
WHERE name = 'Celeriac';

UPDATE vegetables SET pruning_type = 'leaf_removal',
    pruning_tip = 'Remove any yellowing or damaged outer leaves to keep plants tidy and reduce the likelihood of slug damage near the base.'
WHERE name = 'Leek';

UPDATE vegetables SET pruning_type = 'leaf_removal',
    pruning_tip = 'Remove outer leaves that yellow or show signs of disease. Trimming older growth improves airflow and allows more light into the developing head.'
WHERE name IN ('Cabbage', 'Napa Cabbage');

UPDATE vegetables SET pruning_type = 'leaf_removal',
    pruning_tip = 'Snap off lower yellowing leaves as the season progresses to improve airflow, which helps prevent fungal diseases in the dense canopy.'
WHERE name = 'Broccoli';

UPDATE vegetables SET pruning_type = 'leaf_removal',
    pruning_tip = 'Trim back vigorous vines mid-season to keep growth contained and direct more energy into swelling the tubers underground.'
WHERE name = 'Sweet Potato';

UPDATE vegetables SET pruning_type = 'suckering',
    pruning_tip = 'Remove the first 5–6 side shoots to build a strong, vigorous main stem before allowing fruiting laterals to develop. Train the main stem up a vertical support.'
WHERE name = 'Luffa';

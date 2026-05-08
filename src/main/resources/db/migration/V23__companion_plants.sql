CREATE TABLE companion_plants (
    vegetable_id UUID    NOT NULL REFERENCES vegetables(id),
    companion_id UUID    NOT NULL REFERENCES vegetables(id),
    relationship VARCHAR(4) NOT NULL CHECK (relationship IN ('good', 'bad')),
    PRIMARY KEY (vegetable_id, companion_id)
);

-- Helper macro: insert a pair using vegetable names
-- Good companions
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Tomato'    AND v2.name = 'Basil';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Tomato'    AND v2.name = 'Carrot';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Tomato'    AND v2.name = 'Parsley';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Tomato'    AND v2.name = 'Garlic';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Tomato'    AND v2.name = 'Chive';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Tomato'    AND v2.name = 'Celery';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Tomato'    AND v2.name = 'Asparagus';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Carrot'    AND v2.name = 'Leek';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Carrot'    AND v2.name = 'Onion';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Carrot'    AND v2.name = 'Chive';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Carrot'    AND v2.name = 'Rosemary';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Carrot'    AND v2.name = 'Sage';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Carrot'    AND v2.name = 'Lettuce';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Carrot'    AND v2.name = 'Pea';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Pea'       AND v2.name = 'Radish';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Pea'       AND v2.name = 'Mint';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Pea'       AND v2.name = 'Spinach';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Pea'       AND v2.name = 'Turnip';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Bean'      AND v2.name = 'Carrot';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Bean'      AND v2.name = 'Cucumber';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Bean'      AND v2.name = 'Squash';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Bean'      AND v2.name = 'Sweetcorn';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Bean'      AND v2.name = 'Zucchini';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Bean'      AND v2.name = 'Rosemary';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Sweetcorn' AND v2.name = 'Squash';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Sweetcorn' AND v2.name = 'Pumpkin';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Cucumber'  AND v2.name = 'Dill';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Cucumber'  AND v2.name = 'Radish';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Cucumber'  AND v2.name = 'Pea';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Cucumber'  AND v2.name = 'Garlic';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Lettuce'   AND v2.name = 'Radish';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Lettuce'   AND v2.name = 'Onion';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Lettuce'   AND v2.name = 'Spinach';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Lettuce'   AND v2.name = 'Beetroot';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Cabbage'   AND v2.name = 'Dill';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Cabbage'   AND v2.name = 'Rosemary';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Cabbage'   AND v2.name = 'Sage';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Cabbage'   AND v2.name = 'Thyme';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Cabbage'   AND v2.name = 'Mint';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Cabbage'   AND v2.name = 'Celery';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Broccoli'  AND v2.name = 'Onion';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Broccoli'  AND v2.name = 'Celery';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Broccoli'  AND v2.name = 'Garlic';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Onion'     AND v2.name = 'Beetroot';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Garlic'    AND v2.name = 'Beetroot';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Garlic'    AND v2.name = 'Carrot';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Asparagus' AND v2.name = 'Parsley';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Basil'     AND v2.name = 'Bell Pepper';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Basil'     AND v2.name = 'Chili Pepper';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Leek'      AND v2.name = 'Celery';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Eggplant'  AND v2.name = 'Thyme';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Kale'      AND v2.name = 'Celery';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Spinach'   AND v2.name = 'Radish';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Radish'    AND v2.name = 'Chive';

-- Bad companions
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Tomato'  AND v2.name = 'Fennel';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Tomato'  AND v2.name = 'Potato';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Tomato'  AND v2.name = 'Cabbage';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Tomato'  AND v2.name = 'Sweetcorn';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Onion'   AND v2.name = 'Bean';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Onion'   AND v2.name = 'Pea';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Garlic'  AND v2.name = 'Pea';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Garlic'  AND v2.name = 'Bean';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Fennel'  AND v2.name = 'Carrot';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Fennel'  AND v2.name = 'Bell Pepper';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Fennel'  AND v2.name = 'Cucumber';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Fennel'  AND v2.name = 'Eggplant';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Potato'  AND v2.name = 'Cucumber';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Dill'    AND v2.name = 'Carrot';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Leek'    AND v2.name = 'Bean';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Leek'    AND v2.name = 'Pea';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Broccoli' AND v2.name = 'Tomato';
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Cauliflower' AND v2.name = 'Tomato';

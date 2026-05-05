INSERT INTO vegetable_countries (vegetable_id, country_code)
SELECT v.id, m.country_code
FROM vegetables v
JOIN (VALUES
    -- Tomato: warm-season, grown almost everywhere
    ('Tomato', 'AT'), ('Tomato', 'BE'), ('Tomato', 'CH'), ('Tomato', 'CZ'), ('Tomato', 'DE'),
    ('Tomato', 'DK'), ('Tomato', 'ES'), ('Tomato', 'FI'), ('Tomato', 'FR'), ('Tomato', 'GB'),
    ('Tomato', 'HR'), ('Tomato', 'HU'), ('Tomato', 'IE'), ('Tomato', 'IT'), ('Tomato', 'LU'),
    ('Tomato', 'NL'), ('Tomato', 'NO'), ('Tomato', 'PL'), ('Tomato', 'PT'), ('Tomato', 'RO'),
    ('Tomato', 'SE'), ('Tomato', 'SI'), ('Tomato', 'SK'), ('Tomato', 'UA'),
    ('Tomato', 'US'), ('Tomato', 'CA'), ('Tomato', 'MX'), ('Tomato', 'BR'), ('Tomato', 'AR'),
    ('Tomato', 'AU'), ('Tomato', 'NZ'), ('Tomato', 'ZA'), ('Tomato', 'CN'), ('Tomato', 'JP'), ('Tomato', 'IN'),

    -- Cucumber: widely grown, especially under glass in northern Europe
    ('Cucumber', 'AT'), ('Cucumber', 'BE'), ('Cucumber', 'CH'), ('Cucumber', 'CZ'), ('Cucumber', 'DE'),
    ('Cucumber', 'DK'), ('Cucumber', 'ES'), ('Cucumber', 'FI'), ('Cucumber', 'FR'), ('Cucumber', 'GB'),
    ('Cucumber', 'HR'), ('Cucumber', 'HU'), ('Cucumber', 'IE'), ('Cucumber', 'IT'), ('Cucumber', 'LU'),
    ('Cucumber', 'NL'), ('Cucumber', 'NO'), ('Cucumber', 'PL'), ('Cucumber', 'PT'), ('Cucumber', 'RO'),
    ('Cucumber', 'SE'), ('Cucumber', 'SI'), ('Cucumber', 'SK'), ('Cucumber', 'UA'),
    ('Cucumber', 'US'), ('Cucumber', 'CA'), ('Cucumber', 'MX'), ('Cucumber', 'CN'), ('Cucumber', 'JP'),
    ('Cucumber', 'IN'), ('Cucumber', 'AU'), ('Cucumber', 'NZ'), ('Cucumber', 'ZA'),

    -- Bell Pepper: warmer climates; greenhouse in northern Europe
    ('Bell Pepper', 'ES'), ('Bell Pepper', 'IT'), ('Bell Pepper', 'PT'), ('Bell Pepper', 'FR'),
    ('Bell Pepper', 'HR'), ('Bell Pepper', 'HU'), ('Bell Pepper', 'RO'), ('Bell Pepper', 'SI'),
    ('Bell Pepper', 'NL'), ('Bell Pepper', 'BE'), ('Bell Pepper', 'DE'), ('Bell Pepper', 'PL'),
    ('Bell Pepper', 'CZ'), ('Bell Pepper', 'SK'), ('Bell Pepper', 'AT'), ('Bell Pepper', 'CH'),
    ('Bell Pepper', 'GB'), ('Bell Pepper', 'UA'),
    ('Bell Pepper', 'US'), ('Bell Pepper', 'MX'), ('Bell Pepper', 'CN'), ('Bell Pepper', 'IN'),
    ('Bell Pepper', 'BR'), ('Bell Pepper', 'AR'), ('Bell Pepper', 'AU'), ('Bell Pepper', 'ZA'),

    -- Zucchini: widely grown across Europe and beyond
    ('Zucchini', 'AT'), ('Zucchini', 'BE'), ('Zucchini', 'CH'), ('Zucchini', 'CZ'), ('Zucchini', 'DE'),
    ('Zucchini', 'DK'), ('Zucchini', 'ES'), ('Zucchini', 'FR'), ('Zucchini', 'GB'), ('Zucchini', 'HR'),
    ('Zucchini', 'HU'), ('Zucchini', 'IE'), ('Zucchini', 'IT'), ('Zucchini', 'LU'), ('Zucchini', 'NL'),
    ('Zucchini', 'NO'), ('Zucchini', 'PL'), ('Zucchini', 'PT'), ('Zucchini', 'RO'), ('Zucchini', 'SE'),
    ('Zucchini', 'SI'), ('Zucchini', 'SK'), ('Zucchini', 'UA'),
    ('Zucchini', 'US'), ('Zucchini', 'CA'), ('Zucchini', 'AU'), ('Zucchini', 'NZ'), ('Zucchini', 'ZA'),
    ('Zucchini', 'CN'), ('Zucchini', 'BR'), ('Zucchini', 'AR'), ('Zucchini', 'MX'),

    -- Pumpkin: widely grown
    ('Pumpkin', 'AT'), ('Pumpkin', 'BE'), ('Pumpkin', 'CH'), ('Pumpkin', 'CZ'), ('Pumpkin', 'DE'),
    ('Pumpkin', 'DK'), ('Pumpkin', 'ES'), ('Pumpkin', 'FI'), ('Pumpkin', 'FR'), ('Pumpkin', 'GB'),
    ('Pumpkin', 'HR'), ('Pumpkin', 'HU'), ('Pumpkin', 'IE'), ('Pumpkin', 'IT'), ('Pumpkin', 'NL'),
    ('Pumpkin', 'NO'), ('Pumpkin', 'PL'), ('Pumpkin', 'PT'), ('Pumpkin', 'RO'), ('Pumpkin', 'SE'),
    ('Pumpkin', 'SI'), ('Pumpkin', 'SK'), ('Pumpkin', 'UA'),
    ('Pumpkin', 'US'), ('Pumpkin', 'CA'), ('Pumpkin', 'MX'), ('Pumpkin', 'AU'), ('Pumpkin', 'NZ'),
    ('Pumpkin', 'CN'), ('Pumpkin', 'IN'), ('Pumpkin', 'ZA'), ('Pumpkin', 'BR'), ('Pumpkin', 'AR'),

    -- Sweetcorn: warmer climates preferred
    ('Sweetcorn', 'ES'), ('Sweetcorn', 'FR'), ('Sweetcorn', 'IT'), ('Sweetcorn', 'HU'), ('Sweetcorn', 'RO'),
    ('Sweetcorn', 'PL'), ('Sweetcorn', 'DE'), ('Sweetcorn', 'PT'), ('Sweetcorn', 'HR'), ('Sweetcorn', 'SI'),
    ('Sweetcorn', 'SK'), ('Sweetcorn', 'CZ'), ('Sweetcorn', 'AT'), ('Sweetcorn', 'UA'), ('Sweetcorn', 'BE'),
    ('Sweetcorn', 'NL'), ('Sweetcorn', 'GB'), ('Sweetcorn', 'DK'), ('Sweetcorn', 'SE'),
    ('Sweetcorn', 'US'), ('Sweetcorn', 'CA'), ('Sweetcorn', 'MX'), ('Sweetcorn', 'BR'), ('Sweetcorn', 'AR'),
    ('Sweetcorn', 'CN'), ('Sweetcorn', 'IN'), ('Sweetcorn', 'AU'), ('Sweetcorn', 'ZA'),

    -- Lettuce: almost universal
    ('Lettuce', 'AT'), ('Lettuce', 'BE'), ('Lettuce', 'CH'), ('Lettuce', 'CZ'), ('Lettuce', 'DE'),
    ('Lettuce', 'DK'), ('Lettuce', 'ES'), ('Lettuce', 'FI'), ('Lettuce', 'FR'), ('Lettuce', 'GB'),
    ('Lettuce', 'HR'), ('Lettuce', 'HU'), ('Lettuce', 'IE'), ('Lettuce', 'IT'), ('Lettuce', 'LU'),
    ('Lettuce', 'NL'), ('Lettuce', 'NO'), ('Lettuce', 'PL'), ('Lettuce', 'PT'), ('Lettuce', 'RO'),
    ('Lettuce', 'SE'), ('Lettuce', 'SI'), ('Lettuce', 'SK'), ('Lettuce', 'UA'),
    ('Lettuce', 'US'), ('Lettuce', 'CA'), ('Lettuce', 'AU'), ('Lettuce', 'NZ'), ('Lettuce', 'ZA'),
    ('Lettuce', 'CN'), ('Lettuce', 'JP'), ('Lettuce', 'IN'), ('Lettuce', 'BR'), ('Lettuce', 'AR'), ('Lettuce', 'MX'),

    -- Spinach: widely grown
    ('Spinach', 'AT'), ('Spinach', 'BE'), ('Spinach', 'CH'), ('Spinach', 'CZ'), ('Spinach', 'DE'),
    ('Spinach', 'DK'), ('Spinach', 'ES'), ('Spinach', 'FI'), ('Spinach', 'FR'), ('Spinach', 'GB'),
    ('Spinach', 'HR'), ('Spinach', 'HU'), ('Spinach', 'IE'), ('Spinach', 'IT'), ('Spinach', 'NL'),
    ('Spinach', 'NO'), ('Spinach', 'PL'), ('Spinach', 'PT'), ('Spinach', 'RO'), ('Spinach', 'SE'),
    ('Spinach', 'SI'), ('Spinach', 'SK'), ('Spinach', 'UA'),
    ('Spinach', 'US'), ('Spinach', 'CA'), ('Spinach', 'AU'), ('Spinach', 'NZ'), ('Spinach', 'ZA'),
    ('Spinach', 'CN'), ('Spinach', 'JP'), ('Spinach', 'IN'),

    -- Rocket: Mediterranean origin, widely adopted
    ('Rocket', 'IT'), ('Rocket', 'ES'), ('Rocket', 'FR'), ('Rocket', 'PT'), ('Rocket', 'HR'),
    ('Rocket', 'SI'), ('Rocket', 'GB'), ('Rocket', 'NL'), ('Rocket', 'DE'), ('Rocket', 'BE'),
    ('Rocket', 'AT'), ('Rocket', 'CH'), ('Rocket', 'DK'), ('Rocket', 'SE'), ('Rocket', 'IE'),
    ('Rocket', 'US'), ('Rocket', 'AU'), ('Rocket', 'NZ'), ('Rocket', 'ZA'), ('Rocket', 'CA'),

    -- Kale: northern European staple
    ('Kale', 'NL'), ('Kale', 'DE'), ('Kale', 'GB'), ('Kale', 'DK'), ('Kale', 'NO'), ('Kale', 'SE'),
    ('Kale', 'FI'), ('Kale', 'BE'), ('Kale', 'IE'), ('Kale', 'FR'), ('Kale', 'AT'), ('Kale', 'CH'),
    ('Kale', 'PL'), ('Kale', 'CZ'), ('Kale', 'LU'),
    ('Kale', 'US'), ('Kale', 'CA'), ('Kale', 'AU'), ('Kale', 'NZ'),

    -- Cabbage: very widely grown
    ('Cabbage', 'AT'), ('Cabbage', 'BE'), ('Cabbage', 'CH'), ('Cabbage', 'CZ'), ('Cabbage', 'DE'),
    ('Cabbage', 'DK'), ('Cabbage', 'ES'), ('Cabbage', 'FI'), ('Cabbage', 'FR'), ('Cabbage', 'GB'),
    ('Cabbage', 'HR'), ('Cabbage', 'HU'), ('Cabbage', 'IE'), ('Cabbage', 'IT'), ('Cabbage', 'LU'),
    ('Cabbage', 'NL'), ('Cabbage', 'NO'), ('Cabbage', 'PL'), ('Cabbage', 'PT'), ('Cabbage', 'RO'),
    ('Cabbage', 'SE'), ('Cabbage', 'SI'), ('Cabbage', 'SK'), ('Cabbage', 'UA'),
    ('Cabbage', 'US'), ('Cabbage', 'CA'), ('Cabbage', 'AU'), ('Cabbage', 'NZ'), ('Cabbage', 'ZA'),
    ('Cabbage', 'CN'), ('Cabbage', 'JP'), ('Cabbage', 'IN'), ('Cabbage', 'BR'), ('Cabbage', 'AR'),

    -- Broccoli: widely grown, Italian origin
    ('Broccoli', 'IT'), ('Broccoli', 'ES'), ('Broccoli', 'FR'), ('Broccoli', 'GB'), ('Broccoli', 'DE'),
    ('Broccoli', 'NL'), ('Broccoli', 'BE'), ('Broccoli', 'PT'), ('Broccoli', 'IE'), ('Broccoli', 'DK'),
    ('Broccoli', 'AT'), ('Broccoli', 'CH'), ('Broccoli', 'PL'), ('Broccoli', 'CZ'), ('Broccoli', 'HU'),
    ('Broccoli', 'SE'), ('Broccoli', 'HR'), ('Broccoli', 'SI'),
    ('Broccoli', 'US'), ('Broccoli', 'CA'), ('Broccoli', 'AU'), ('Broccoli', 'NZ'), ('Broccoli', 'ZA'),
    ('Broccoli', 'CN'), ('Broccoli', 'JP'), ('Broccoli', 'IN'),

    -- Cauliflower: widely grown
    ('Cauliflower', 'FR'), ('Cauliflower', 'GB'), ('Cauliflower', 'IT'), ('Cauliflower', 'NL'),
    ('Cauliflower', 'DE'), ('Cauliflower', 'BE'), ('Cauliflower', 'ES'), ('Cauliflower', 'PT'),
    ('Cauliflower', 'DK'), ('Cauliflower', 'IE'), ('Cauliflower', 'AT'), ('Cauliflower', 'CH'),
    ('Cauliflower', 'PL'), ('Cauliflower', 'CZ'), ('Cauliflower', 'HR'), ('Cauliflower', 'SI'),
    ('Cauliflower', 'US'), ('Cauliflower', 'CA'), ('Cauliflower', 'AU'), ('Cauliflower', 'IN'),
    ('Cauliflower', 'ZA'), ('Cauliflower', 'CN'), ('Cauliflower', 'JP'),

    -- Carrot: universal
    ('Carrot', 'AT'), ('Carrot', 'BE'), ('Carrot', 'CH'), ('Carrot', 'CZ'), ('Carrot', 'DE'),
    ('Carrot', 'DK'), ('Carrot', 'ES'), ('Carrot', 'FI'), ('Carrot', 'FR'), ('Carrot', 'GB'),
    ('Carrot', 'HR'), ('Carrot', 'HU'), ('Carrot', 'IE'), ('Carrot', 'IT'), ('Carrot', 'LU'),
    ('Carrot', 'NL'), ('Carrot', 'NO'), ('Carrot', 'PL'), ('Carrot', 'PT'), ('Carrot', 'RO'),
    ('Carrot', 'SE'), ('Carrot', 'SI'), ('Carrot', 'SK'), ('Carrot', 'UA'),
    ('Carrot', 'US'), ('Carrot', 'CA'), ('Carrot', 'AU'), ('Carrot', 'NZ'), ('Carrot', 'ZA'),
    ('Carrot', 'CN'), ('Carrot', 'JP'), ('Carrot', 'IN'), ('Carrot', 'BR'), ('Carrot', 'AR'),

    -- Radish: widely grown
    ('Radish', 'AT'), ('Radish', 'BE'), ('Radish', 'CH'), ('Radish', 'CZ'), ('Radish', 'DE'),
    ('Radish', 'DK'), ('Radish', 'ES'), ('Radish', 'FI'), ('Radish', 'FR'), ('Radish', 'GB'),
    ('Radish', 'HR'), ('Radish', 'HU'), ('Radish', 'IE'), ('Radish', 'IT'), ('Radish', 'NL'),
    ('Radish', 'NO'), ('Radish', 'PL'), ('Radish', 'PT'), ('Radish', 'RO'), ('Radish', 'SE'),
    ('Radish', 'SI'), ('Radish', 'SK'), ('Radish', 'UA'),
    ('Radish', 'US'), ('Radish', 'CA'), ('Radish', 'AU'), ('Radish', 'NZ'), ('Radish', 'CN'), ('Radish', 'JP'),

    -- Beetroot: northern/central European stronghold
    ('Beetroot', 'GB'), ('Beetroot', 'DE'), ('Beetroot', 'NL'), ('Beetroot', 'PL'), ('Beetroot', 'SE'),
    ('Beetroot', 'DK'), ('Beetroot', 'NO'), ('Beetroot', 'FI'), ('Beetroot', 'FR'), ('Beetroot', 'BE'),
    ('Beetroot', 'AT'), ('Beetroot', 'CH'), ('Beetroot', 'CZ'), ('Beetroot', 'SK'), ('Beetroot', 'HU'),
    ('Beetroot', 'RO'), ('Beetroot', 'UA'), ('Beetroot', 'IE'), ('Beetroot', 'LU'),
    ('Beetroot', 'US'), ('Beetroot', 'CA'), ('Beetroot', 'AU'), ('Beetroot', 'NZ'), ('Beetroot', 'ZA'),

    -- Onion: universal
    ('Onion', 'AT'), ('Onion', 'BE'), ('Onion', 'CH'), ('Onion', 'CZ'), ('Onion', 'DE'),
    ('Onion', 'DK'), ('Onion', 'ES'), ('Onion', 'FI'), ('Onion', 'FR'), ('Onion', 'GB'),
    ('Onion', 'HR'), ('Onion', 'HU'), ('Onion', 'IE'), ('Onion', 'IT'), ('Onion', 'LU'),
    ('Onion', 'NL'), ('Onion', 'NO'), ('Onion', 'PL'), ('Onion', 'PT'), ('Onion', 'RO'),
    ('Onion', 'SE'), ('Onion', 'SI'), ('Onion', 'SK'), ('Onion', 'UA'),
    ('Onion', 'US'), ('Onion', 'CA'), ('Onion', 'MX'), ('Onion', 'BR'), ('Onion', 'AR'),
    ('Onion', 'AU'), ('Onion', 'NZ'), ('Onion', 'ZA'), ('Onion', 'CN'), ('Onion', 'JP'), ('Onion', 'IN'),

    -- Leek: western and northern European staple
    ('Leek', 'BE'), ('Leek', 'FR'), ('Leek', 'NL'), ('Leek', 'GB'), ('Leek', 'DE'), ('Leek', 'CH'),
    ('Leek', 'AT'), ('Leek', 'IE'), ('Leek', 'DK'), ('Leek', 'SE'), ('Leek', 'NO'), ('Leek', 'FI'),
    ('Leek', 'PL'), ('Leek', 'CZ'), ('Leek', 'LU'), ('Leek', 'HU'), ('Leek', 'IT'), ('Leek', 'ES'),
    ('Leek', 'US'), ('Leek', 'AU'), ('Leek', 'CA'), ('Leek', 'NZ'),

    -- Pea: temperate climates
    ('Pea', 'GB'), ('Pea', 'FR'), ('Pea', 'DE'), ('Pea', 'NL'), ('Pea', 'BE'), ('Pea', 'DK'),
    ('Pea', 'SE'), ('Pea', 'NO'), ('Pea', 'FI'), ('Pea', 'IE'), ('Pea', 'AT'), ('Pea', 'CH'),
    ('Pea', 'PL'), ('Pea', 'CZ'), ('Pea', 'SK'), ('Pea', 'HU'), ('Pea', 'ES'), ('Pea', 'IT'),
    ('Pea', 'LU'), ('Pea', 'UA'),
    ('Pea', 'US'), ('Pea', 'CA'), ('Pea', 'AU'), ('Pea', 'NZ'), ('Pea', 'IN'), ('Pea', 'CN'),

    -- Bean: widely grown
    ('Bean', 'AT'), ('Bean', 'BE'), ('Bean', 'CH'), ('Bean', 'CZ'), ('Bean', 'DE'),
    ('Bean', 'DK'), ('Bean', 'ES'), ('Bean', 'FR'), ('Bean', 'GB'), ('Bean', 'HR'),
    ('Bean', 'HU'), ('Bean', 'IE'), ('Bean', 'IT'), ('Bean', 'NL'), ('Bean', 'PL'),
    ('Bean', 'PT'), ('Bean', 'RO'), ('Bean', 'SE'), ('Bean', 'SI'), ('Bean', 'SK'), ('Bean', 'UA'),
    ('Bean', 'US'), ('Bean', 'CA'), ('Bean', 'MX'), ('Bean', 'BR'), ('Bean', 'AR'),
    ('Bean', 'AU'), ('Bean', 'NZ'), ('Bean', 'ZA'), ('Bean', 'CN'), ('Bean', 'IN'),

    -- Parsley: very widely grown
    ('Parsley', 'AT'), ('Parsley', 'BE'), ('Parsley', 'CH'), ('Parsley', 'CZ'), ('Parsley', 'DE'),
    ('Parsley', 'DK'), ('Parsley', 'ES'), ('Parsley', 'FI'), ('Parsley', 'FR'), ('Parsley', 'GB'),
    ('Parsley', 'HR'), ('Parsley', 'HU'), ('Parsley', 'IE'), ('Parsley', 'IT'), ('Parsley', 'LU'),
    ('Parsley', 'NL'), ('Parsley', 'NO'), ('Parsley', 'PL'), ('Parsley', 'PT'), ('Parsley', 'RO'),
    ('Parsley', 'SE'), ('Parsley', 'SI'), ('Parsley', 'SK'), ('Parsley', 'UA'),
    ('Parsley', 'US'), ('Parsley', 'CA'), ('Parsley', 'AU'), ('Parsley', 'NZ'), ('Parsley', 'ZA'),
    ('Parsley', 'BR'), ('Parsley', 'AR'),

    -- Basil: warm climate, Mediterranean origin
    ('Basil', 'IT'), ('Basil', 'ES'), ('Basil', 'FR'), ('Basil', 'PT'), ('Basil', 'HR'),
    ('Basil', 'SI'), ('Basil', 'NL'), ('Basil', 'DE'), ('Basil', 'BE'), ('Basil', 'CH'),
    ('Basil', 'AT'), ('Basil', 'GB'), ('Basil', 'IE'), ('Basil', 'DK'), ('Basil', 'SE'),
    ('Basil', 'US'), ('Basil', 'CA'), ('Basil', 'AU'), ('Basil', 'NZ'), ('Basil', 'ZA'),
    ('Basil', 'IN'), ('Basil', 'JP'), ('Basil', 'MX'), ('Basil', 'BR'), ('Basil', 'AR'),

    -- Dill: northern and eastern European staple
    ('Dill', 'DE'), ('Dill', 'PL'), ('Dill', 'CZ'), ('Dill', 'SK'), ('Dill', 'HU'), ('Dill', 'RO'),
    ('Dill', 'UA'), ('Dill', 'DK'), ('Dill', 'SE'), ('Dill', 'NO'), ('Dill', 'FI'), ('Dill', 'AT'),
    ('Dill', 'NL'), ('Dill', 'FR'), ('Dill', 'GB'), ('Dill', 'BE'), ('Dill', 'CH'),
    ('Dill', 'US'), ('Dill', 'CA'), ('Dill', 'AU'),

    -- Fennel: Mediterranean specialty
    ('Fennel', 'IT'), ('Fennel', 'ES'), ('Fennel', 'FR'), ('Fennel', 'PT'), ('Fennel', 'HR'),
    ('Fennel', 'SI'), ('Fennel', 'DE'), ('Fennel', 'NL'), ('Fennel', 'GB'), ('Fennel', 'BE'),
    ('Fennel', 'AT'), ('Fennel', 'CH'), ('Fennel', 'DK'), ('Fennel', 'SE'),
    ('Fennel', 'US'), ('Fennel', 'CA'), ('Fennel', 'AU'), ('Fennel', 'ZA'), ('Fennel', 'IN')
) AS m(veg_name, country_code) ON v.name = m.veg_name;

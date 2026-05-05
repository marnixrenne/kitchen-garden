CREATE TABLE countries (
    code CHAR(2)     PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE vegetable_countries (
    vegetable_id UUID   NOT NULL,
    country_code CHAR(2) NOT NULL,
    CONSTRAINT fk_vc_vegetable FOREIGN KEY (vegetable_id) REFERENCES vegetables (id),
    CONSTRAINT fk_vc_country   FOREIGN KEY (country_code) REFERENCES countries (code),
    CONSTRAINT pk_vc            PRIMARY KEY (vegetable_id, country_code)
);

INSERT INTO countries (code, name) VALUES
    ('AT', 'Austria'),
    ('BE', 'Belgium'),
    ('CH', 'Switzerland'),
    ('CZ', 'Czech Republic'),
    ('DE', 'Germany'),
    ('DK', 'Denmark'),
    ('ES', 'Spain'),
    ('FI', 'Finland'),
    ('FR', 'France'),
    ('GB', 'United Kingdom'),
    ('HR', 'Croatia'),
    ('HU', 'Hungary'),
    ('IE', 'Ireland'),
    ('IT', 'Italy'),
    ('LU', 'Luxembourg'),
    ('NL', 'Netherlands'),
    ('NO', 'Norway'),
    ('PL', 'Poland'),
    ('PT', 'Portugal'),
    ('RO', 'Romania'),
    ('SE', 'Sweden'),
    ('SI', 'Slovenia'),
    ('SK', 'Slovakia'),
    ('UA', 'Ukraine'),
    ('US', 'United States'),
    ('CA', 'Canada'),
    ('AU', 'Australia'),
    ('NZ', 'New Zealand'),
    ('ZA', 'South Africa'),
    ('JP', 'Japan'),
    ('CN', 'China'),
    ('IN', 'India'),
    ('BR', 'Brazil'),
    ('AR', 'Argentina'),
    ('MX', 'Mexico');

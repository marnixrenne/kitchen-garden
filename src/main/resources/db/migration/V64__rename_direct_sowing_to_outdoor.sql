-- V64: Rename sowing_method value 'direct' to 'outdoor' for clarity.

UPDATE pts_plants SET sowing_method = 'outdoor' WHERE sowing_method = 'direct';

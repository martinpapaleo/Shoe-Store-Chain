UPDATE sandbox.stock_demo SET qty = 10 WHERE product = 'Runner X';

CREATE TABLE sandbox.sale_demo (
  id         INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  product_id INT NOT NULL REFERENCES sandbox.stock_demo(id),
  units      INT NOT NULL CHECK (units > 0)
);

SELECT * FROM sandbox.sale_demo;